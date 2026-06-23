#!/bin/bash
# =======================================================
# PANEL CENTRAL - ADMINISTRACIÓN DE INFRAESTRUCTURA
# =======================================================

source ./linux/modules/utils.sh
source ./linux/modules/dhcp_modules.sh
source ./linux/modules/dns_modules.sh
source ./linux/modules/ftp_modules.sh

# Validar privilegios de ejecución iniciales
check_root_access

while :; do
    clear
    echo -e "\e[1;35m┌──────────────────────────────────────────────────────────┐\e[0m"
    echo -e "\e[1;35m│          CONSOLA DE GESTIÓN Y DESPLIEGUE MODULAR         │\e[0m"
    echo -e "\e[1;35m└──────────────────────────────────────────────────────────┘\e[0m"
    echo -e "  [A] Implementar Servidor DHCP Dinámico"
    echo -e "  [B] Implementar Servidor DNS (reprobados.com)"
    echo -e "  [C] Implementar Servidor FTP Seguro (vsftpd)"
    echo -e "  [Q] Finalizar y Salir"
    echo -e "\e[1;35m────────────────────────────────────────────────────────────\e[0m"
    read -p " Seleccione una operación de la lista [A-Q]: " SELECCION

    case ${SELECCION^^} in
        A) run_dhcp_deployment; read -p "Presione [Enter] para continuar..." ;;
        B) run_dns_deployment; read -p "Presione [Enter] para continuar..." ;;
        C) run_ftp_deployment; read -p "Presione [Enter] para continuar..." ;;
        Q) echo "Cerrando la consola de administración."; exit 0 ;;
        *) echo "Opción no reconocida por el sistema."; sleep 1 ;;
    esac
done
