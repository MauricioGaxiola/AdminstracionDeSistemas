#!/bin/bash

function run_ftp_deployment() {
    echo -e "\n\e[1;34m▶ Iniciando Módulo: Servidor FTP (VSFTPD)\e[0m"
    verify_and_install "vsftpd"

    echo "[*] Configurando dependencias de seguridad e identidades..."
    getent group reprobados >/dev/null || groupadd reprobados
    getent group recursadores >/dev/null || groupadd recursadores

    echo "[*] Levantando árbol de almacenamiento global..."
    mkdir -p /var/ftp/shared/{general,reprobados,recursadores}
    mkdir -p /var/ftp/anon/general

    # Asignación estricta de ACLs
    chmod 777 /var/ftp/shared/general
    chown root:reprobados /var/ftp/shared/reprobados && chmod 770 /var/ftp/shared/reprobados
    chown root:recursadores /var/ftp/shared/recursadores && chmod 770 /var/ftp/shared/recursadores

    # Enlace de visibilidad anónima
    mount --bind /var/ftp/shared/general /var/ftp/anon/general > /dev/null 2>&1
    chmod 555 /var/ftp/anon /var/ftp/anon/general

    echo "[*] Reemplazando parámetros en /etc/vsftpd.conf..."
    [[ ! -f /etc/vsftpd.conf.bak ]] && cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
    
    sudo tee /etc/vsftpd.conf > /dev/null << EOF
listen=YES
listen_ipv6=NO
anonymous_enable=YES
anon_root=/var/ftp/anon
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
EOF

    systemctl restart vsftpd
    systemctl enable vsftpd > /dev/null 2>&1

    echo -e "\n--- Alta Masiva de Usuarios ---"
    read -p "Cantidad de cuentas a registrar (n): " total_users
    
    for (( c=1; c<=total_users; c++ )); do
        echo -e "\n\e[1;33m[+] Datos del Usuario [$c/$total_users]\e[0m"
        read -p " Nombre de usuario: " current_user
        read -s -p " Clave de acceso: " current_pass; echo ""
        read -p " Grupo de adscripción (reprobados/recursadores): " current_group

        if [[ "$current_group" != "reprobados" && "$current_group" != "recursadores" ]]; then
            echo -e "[!] Entrada inválida. Default: reprobados."
            current_group="reprobados"
        fi

        if id "$current_user" &>/dev/null; then
            echo "[*] Identidad existente. Migrando de grupo..."
            usermod -g $current_group $current_user
        else
            useradd -g $current_group -d /home/$current_user -s /sbin/nologin $current_user
        fi
        
        echo "$current_user:$current_pass" | chpasswd

        # Construcción visual unificada requerida
        mkdir -p /home/$current_user/{general,$current_group,$current_user}
        chown -R $current_user:$current_group /home/$current_user

        # Montaje dinámico de carpetas
        mount --bind /var/ftp/shared/general /home/$current_user/general > /dev/null 2>&1
        mount --bind /var/ftp/shared/$current_group /home/$current_user/$current_group > /dev/null 2>&1
        
        echo -e "\e[1;32m[OK] Estructura virtualizada generada para $current_user.\e[0m"
    done
}
