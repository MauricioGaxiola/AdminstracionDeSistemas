#!/bin/bash

function run_dhcp_deployment() {
    echo -e "\n\e[1;34m▶ Iniciando Módulo: Servidor DHCP\e[0m"
    verify_and_install "isc-dhcp-server"

    echo -e "\n--- Configuración del Ámbito de Red ---"
    read -p " Tiempo de concesión base (Lease en seg, ej. 600): " lease_base
    read -p " Dirección IP Inicial del rango: " ip_start
    read -p " Dirección IP Final del rango: " ip_end
    read -p " Puerta de Enlace (Gateway): " gw_ip
    read -p " Servidor DNS Principal: " dns_server

    echo "[*] Reestructurando archivo maestro /etc/dhcp/dhcpd.conf..."
    sudo tee /etc/dhcp/dhcpd.conf > /dev/null << EOF
default-lease-time $lease_base;
max-lease-time 7200;
authoritative;

subnet 192.168.50.0 netmask 255.255.255.0 {
    range $ip_start $ip_end;
    option routers $gw_ip;
    option domain-name-servers $dns_server;
}
EOF
    
    echo "[*] Aplicando reinicio al demonio isc-dhcp-server..."
    systemctl restart isc-dhcp-server
    systemctl enable isc-dhcp-server > /dev/null 2>&1
    
    echo -e "\n\e[1;32m[+] Configuración de DHCP completada exitosamente.\e[0m"
    echo -e "\e[1;36m=== MONITORIZACIÓN DEL SERVICIO ===\e[0m"
    systemctl status isc-dhcp-server | grep -E "Active:"
    echo "[*] Historial de arrendamientos (/var/lib/dhcp/dhcpd.leases):"
    tail -n 10 /var/lib/dhcp/dhcpd.leases 2>/dev/null || echo "[Aviso] Sin concesiones registradas aún."
}
