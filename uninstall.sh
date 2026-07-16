#!/bin/bash

set -e

APP_NAME="Crafty Controller"
APP_USER="crafty"
APP_DIR="/opt/crafty"
SERVICE_NAME="crafty"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() {
    echo "[INFO] $1"
}

error() {
    echo "[ERRO] $1"
    exit 1
}

check_root() {

    if [ "$EUID" -ne 0 ]; then
        error "Execute como root: sudo ./uninstall.sh"
    fi
}

check_installation() {

    if [ ! -d "$APP_DIR" ]; then
        error "Nenhuma instalacao encontrada em $APP_DIR"
    fi

    info "Instalacao encontrada em $APP_DIR"
}

stop_service() {

    if systemctl list-units --all | grep -q "${SERVICE_NAME}.service"; then

        info "Parando servico Crafty"

        systemctl stop "$SERVICE_NAME" || true

        info "Servico parado"

    else

        info "Servico Crafty nao encontrado"

    fi
}

ask_keep_servers() {

    echo
    echo "O que deseja fazer com os servidores Minecraft?"
    echo
    echo "1) Manter servidores"
    echo "   (mundos e configuracoes serao preservados)"
    echo
    echo "2) Remover tudo"
    echo "   (servidores tambem serao apagados)"
    echo

    read -rp "Opcao [1]: " OPTION

    case "$OPTION" in
        2)
            KEEP_SERVERS=false
            ;;
        *)
            KEEP_SERVERS=true
            ;;
    esac
}

remove_files() {

    if [ "$KEEP_SERVERS" = false ]; then

        info "Removendo instalacao completa"

        rm -rf "$APP_DIR"

        info "Removendo usuario $APP_USER"

        userdel -r "$APP_USER" 2>/dev/null || true

    else

        info "Mantendo servidores Minecraft"

        rm -rf "$APP_DIR/app"
        rm -rf "$APP_DIR/config"
        rm -rf "$APP_DIR/logs"
        rm -rf "$APP_DIR/backups"

        chown -R "$APP_USER:$APP_USER" "$APP_DIR/servers"
        info "Mantendo usuario $APP_USER"

    fi

    info "Arquivos removidos"
}

confirm_uninstall() {

    echo
    echo "A instalacao do Crafty sera removida."
    echo "Esta acao nao pode ser desfeita."
    echo

    read -rp "Deseja continuar? [s/N]: " CONFIRM

    case "$CONFIRM" in
        s|S)
            info "Remocao confirmada"
            ;;
        *)
            info "Operacao cancelada"
            exit 0
            ;;
    esac
}

remove_service() {

    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then

        info "Removendo servico systemd"

        systemctl disable "$SERVICE_NAME" >/dev/null 2>&1 || true

        rm -f "/etc/systemd/system/${SERVICE_NAME}.service"

        systemctl daemon-reload
        
        systemctl reset-failed

        info "Servico systemd removido"

    else

        info "Arquivo de servico nao encontrado"

    fi
}

main() {

    echo "=========================================="
    echo "   $APP_NAME Uninstaller"
    echo "=========================================="
    echo

    check_root
    check_installation
    confirm_uninstall
    stop_service
    remove_service
    ask_keep_servers
    remove_files
    
}

main
