# =======================================================
# PANEL CENTRAL - ORQUESTACIÓN DE REDES EN WINDOWS 
# =======================================================

# Importación cruzada usando llamadas por bloque (Dot-Sourcing)
. .\Modules\Utils.ps1
. .\Modules\DhcpModules.ps1
. .\Modules\DnsModules.ps1
. .\Modules\FtpModules.ps1

Assert-AdministratorPrivileges

do {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║          SISTEMA DE PROVISIÓN AUTOMATIZADA (POWERSHELL)  ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "  [1] Desplegar Servidor de Direccionamiento (DHCP)"
    Write-Host "  [2] Desplegar Servidor de Nombres de Dominio (DNS)"
    Write-Host "  [3] Desplegar Servidor de Transferencia (FTP/IIS)"
    Write-Host "  [4] Apagar Consola"
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
    $MenuSelection = Read-Host " Ingrese el índice de la tarea a ejecutar [1-4]"

    switch ($MenuSelection) {
        '1' { Start-DhcpAutomation ; Pause }
        '2' { Start-DnsAutomation ; Pause }
        '3' { Start-FtpAutomation ; Pause }
        '4' { Write-Host "Cerrando sesión del Orquestador..." -ForegroundColor Gray }
        default { Write-Host "Selección fuera de rango." -ForegroundColor Red ; Start-Sleep -Seconds 1 }
    }
} while ($MenuSelection -ne '4')
