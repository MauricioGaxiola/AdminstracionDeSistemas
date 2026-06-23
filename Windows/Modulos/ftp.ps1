function Start-FtpAutomation {
    Write-Host "`n▶ Ejecutando Módulo: Servidor FTP (IIS)" -ForegroundColor Green
    
    $FtpCheck = Get-WindowsFeature -Name Web-Ftp-Server
    if (-not $FtpCheck.Installed) {
        Write-Host "[*] Activando características secundarias de IIS FTP Server..." -ForegroundColor Yellow
        Install-WindowsFeature -Name Web-Ftp-Server, Web-Mgmt-Console -IncludeManagementTools | Out-Null
    } else {
        Write-Host "[IDEMPOTENTE] El Rol IIS FTP ya está activo en el sistema." -ForegroundColor Cyan
    }

    Write-Host "[*] Validando consistencia de Grupos Locales..."
    $TargetGroups = @("reprobados", "recursadores")
    foreach ($Grp in $TargetGroups) {
        if (-not (Get-LocalGroup -Name $Grp -ErrorAction SilentlyContinue)) {
            New-LocalGroup -Name $Grp -Description "Acceso restringido FTP $Grp" | Out-Null
        }
    }

    $RootPath = "C:\inetpub\ftproot"
    Write-Host "[*] Estructurando almacenamiento estático en $RootPath..."
    @("general", "reprobados", "recursadores") | ForEach-Object {
        if (-not (Test-Path "$RootPath\$_")) { New-Item -Path "$RootPath\$_" -ItemType Directory | Out-Null }
    }

    # Creación y parametrización del Sitio FTP en IIS
    Import-Module WebAdministration
    if (-not (Test-Path "IIS:\Sites\SitioFTP")) {
        New-WebFtpSite -Name "SitioFTP" -Port 21 -PhysicalPath $RootPath | Out-Null
        Set-ItemProperty "IIS:\Sites\SitioFTP" -Name "ftpServer.security.ssl.controlChannelPolicy" -Value "SslAllow"
        Set-ItemProperty "IIS:\Sites\SitioFTP" -Name "ftpServer.security.ssl.dataChannelPolicy" -Value "SslAllow"
        Set-ItemProperty "IIS:\Sites\SitioFTP" -Name "ftpServer.security.authentication.basicAuthentication.enabled" -Value $true
        Set-ItemProperty "IIS:\Sites\SitioFTP" -Name "ftpServer.security.anonymousAuthentication.enabled" -Value $true
        Restart-Service ftpsvc
    }

    $TotalAccounts = Read-Host "`n Cantidad de usuarios a aprovisionar (n)"
    
    for ($idx = 1; $idx -le [int]$TotalAccounts; $idx++) {
        Write-Host "`n--- Cuenta de Usuario [$idx/$TotalAccounts] ---" -ForegroundColor Yellow
        $FtpUser = Read-Host " Nombre de usuario"
        $FtpPass = Read-Host " Clave de seguridad" -AsSecureString
        $FtpGroup = Read-Host " Grupo (reprobados/recursadores)"
        
        if ($FtpGroup -ne "reprobados" -and $FtpGroup -ne "recursadores") {
            $FtpGroup = "reprobados"
        }

        # Alta lógica de cuenta local
        try {
            New-LocalUser -Name $FtpUser -Password $FtpPass -PasswordNeverExpires -ErrorAction Stop | Out-Null
        } catch {
            Write-Host "[*] Cuenta existente. Regenerando políticas..."
        }

        Add-LocalGroupMember -Group $FtpGroup -Member $FtpUser -ErrorAction SilentlyContinue

        # Generación del Directorio Raíz Virtual Requerido
        $UserWorkspace = "$RootPath\$FtpUser"
        if (-not (Test-Path $UserWorkspace)) { New-Item -Path $UserWorkspace -ItemType Directory | Out-Null }
        
        # Despliegue de seguridad NTFS (ACLs avanzadas)
        $FolderAcl = Get-Acl $UserWorkspace
        $PermissionRule = New-Object System.Security.AccessControl.FileSystemAccessRule($FtpUser, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
        $FolderAcl.AddAccessRule($PermissionRule)
        Set-Acl $UserWorkspace $FolderAcl

        Write-Host "[+] Estructura y herencia NTFS listas para el usuario: $FtpUser." -ForegroundColor Cyan
    }
}
