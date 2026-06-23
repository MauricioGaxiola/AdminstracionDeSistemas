function Start-DnsAutomation {
    Write-Host "`n▶ Ejecutando Módulo: Servidor DNS" -ForegroundColor Green
    
    $DnsCheck = Get-WindowsFeature -Name DNS
    if (-not $DnsCheck.Installed) {
        Write-Host "[*] Instalando binarios del Rol DNS corporativo..." -ForegroundColor Yellow
        Install-WindowsFeature -Name DNS -IncludeManagementTools | Out-Null
    } else {
        Write-Host "[IDEMPOTENTE] El servicio de DNS ya se encuentra operativo." -ForegroundColor Cyan
    }

    $TargetDomain = "reprobados.com"
    $ResolutionIP = Read-Host " Ingrese la dirección IP asociada a este dominio"
    
    try {
        # Creación de Zona Primaria e inserción de registros A
        Add-DnsServerPrimaryZone -Name $TargetDomain -ZoneFile "$TargetDomain.dns" -ErrorAction Stop | Out-Null
        Add-DnsServerResourceRecordA -ZoneName $TargetDomain -Name "@" -IPv4Address $ResolutionIP -ErrorAction Stop | Out-Null
        Add-DnsServerResourceRecordA -ZoneName $TargetDomain -Name "www" -IPv4Address $ResolutionIP -ErrorAction Stop | Out-Null
        
        Write-Host "[+] Zona de búsqueda directa para '$TargetDomain' vinculada a $ResolutionIP." -ForegroundColor Cyan
    } catch {
        Write-Host "[!] Advertencia: La zona o los registros de resolución ya existen en este nodo." -ForegroundColor Yellow
    }
}
