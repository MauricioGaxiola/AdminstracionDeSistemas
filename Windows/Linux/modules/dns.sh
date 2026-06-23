#!/bin/bash

function run_dns_deployment() {
    echo -e "\n\e[1;34m▶ Iniciando Módulo: Servidor DNS (BIND9)\e[0m"
    verify_and_install "bind9"
    verify_and_install "bind9utils"
    
    local zone_domain="reprobados.com"
    local local_host_ip="192.168.50.10"
    
    echo -e "\n--- Configuración de Resolución de Nombres ---"
    read -p " Ingrese la IP destino para $zone_domain: " mapping_ip

    echo "[*] Modificando /etc/bind/named.conf.local..."
    sudo tee /etc/bind/named.conf.local > /dev/null << EOF
zone "$zone_domain" {
    type master;
    file "/var/cache/bind/db.$zone_domain";
};
EOF

    echo "[*] Estructurando archivo de zona db.$zone_domain..."
    sudo tee /var/cache/bind/db.$zone_domain > /dev/null << EOF
\$TTL    86400
@       IN      SOA     ns1.$zone_domain. root.$zone_domain. (
                     2026062301         ; Serial Único
                         3600           ; Refresh
                          900           ; Retry
                        604800          ; Expire
                         86400 )        ; Minimum TTL
@       IN      NS      ns1.$zone_domain.
ns1     IN      A       $local_host_ip
@       IN      A       $mapping_ip
www     IN      A       $mapping_ip
EOF

    echo "[*] Ejecutando validación de sintaxis declarativa..."
    if named-checkconf /etc/bind/named.conf.local; then
        echo -e "\e[1;32m[OK] Verificación de archivos de BIND9 aprobada.\e[0m"
        systemctl restart bind9
        systemctl enable bind9 > /dev/null 2>&1
        echo -e "\e[1;32m[+] Zonas activas en el puerto 53.\e[0m"
    else
        echo -e "\e[1;31m[FAIL] Error en la estructura del archivo DNS.\e[0m"
    fi
}
