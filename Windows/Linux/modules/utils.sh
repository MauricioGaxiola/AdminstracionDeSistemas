#!/bin/bash

function check_root_access() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "\e[1;31m[-] Error crítico: Se requieren privilegios de superusuario (sudo).\e[0m"
        exit 1
    fi
}

function verify_and_install() {
    local target_pkg=$1
    echo -e "\e[1;34m[*] Verificando estado del paquete: $target_pkg...\e[0m"
    
    if qstat=$(dpkg-query -W -f='${Status}' "$target_pkg" 2>/dev/null) && [[ "$qstat" == *"ok installed"* ]]; then
        echo -e "\e[1;32m[IDEMPOTENTE] El paquete '$target_pkg' ya se encuentra operativo.\e[0m"
    else
        echo -e "\e[1;33m[*] Desplegando instalación automatizada para: $target_pkg...\e[0m"
        apt-get update > /dev/null
        DEBIAN_FRONTEND=noninteractive apt-get install -y "$target_pkg" > /dev/null
    fi
}
