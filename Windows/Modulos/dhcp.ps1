function Start-DhcpAutomation {
    Write-Host "`n▶ Ejecutando Módulo: Servidor DHCP" -ForegroundColor Green
    
    $FeatureStatus = Get-WindowsFeature -Name DHCP
    if ($FeatureStatus.Installed) {
        Write-Host "[IDEMPOTENTE] Las características de DHCP ya se encuentran integradas." -ForegroundColor Cyan
    } else {
        Write-Host "[*] Añadiendo rol DHCP de manera silenciosa..." -ForegroundColor Yellow
        Install-WindowsFeature -Name DHCP -IncludeManagementTools | Out-Null
    }
    
    $ScopeAlias = Read-Host " Identificador del Ámbito (ej. Red_UAS)"
    $IPMin = Read-Host " Dirección IP Inicial del Pool"
    $IPMax = Read-Host " Dirección IP Final del Pool"
    $GatewayIP = Read-Host " Puerta de enlace predeterminada"
    $DnsIP = Read-Host " Servidor de nombres local"
    
    try {
        # Alta del Ámbito Lógico
        Add-DhcpServerv4Scope -Name $ScopeAlias -StartRange $IPMin -EndRange $IPMax -SubnetMask 255.255.255.0 -ErrorAction Stop | Out-Null
        
        # Inyección de parámetros adicionales solicitados
        Set-DhcpServerv4OptionValue -ScopeId $IPMin -Router $GatewayIP -DnsServer $DnsIP | Out-Null
        
        Write-Host "[+] Ámbito de red '$ScopeAlias' provisto exitosamente." -ForegroundColor Cyan
        
        # Módulo de Monitoreo Integrado
        Write-Host "`n=== RENDIMIENTO Y DIAGNÓSTICO ===" -ForegroundColor Green
        Get-Service -Name DHCPServer | Select-Object Name, Status, DisplayName
        Write-Host "[*] Concesiones activas en tiempo real:"
        Get-DhcpServerv4Lease -ScopeId $IPMin
    } catch {
        Write-Host "[!] Error en despliegue: $_" -ForegroundColor Red
    }
}
