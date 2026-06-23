function Assert-AdministratorPrivileges {
    $CurrentUserToken = [Security.Principal.WindowsIdentity]::GetCurrent()
    $SecurityEvaluation = New-Object Security.Principal.WindowsPrincipal($CurrentUserToken)
    $IsAdmin = $SecurityEvaluation.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $IsAdmin) {
        Write-Error "[-] Denegado: Este script requiere una consola de PowerShell con privilegios elevados."
        Exit
    }
}
