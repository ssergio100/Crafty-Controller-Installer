#!/bin/bash

set -e

APP_NAME="Crafty Controller"
APP_USER="crafty"
APP_DIR="/opt/crafty"
CRAFTY_DIR="/opt/crafty/app/crafty"
SERVICE_NAME="crafty"

info() {
    echo "[INFO] $1"
}

error() {
    echo "[ERRO] $1"
    exit 1
}

check_root() {

    if [ "$EUID" -ne 0 ]; then
        error "Execute como root: sudo ./update.sh"
    fi
}

check_installation() {

    if [ ! -d "$CRAFTY_DIR" ]; then
        error "Instalacao do Crafty nao encontrada em $CRAFTY_DIR"
    fi

    info "Instalacao encontrada em $CRAFTY_DIR"
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

update_code() {

    info "Atualizando codigo do Crafty"

    sudo -u "$APP_USER" git -C "$CRAFTY_DIR" pull

    VERSION=$(sudo -u "$APP_USER" git -C "$CRAFTY_DIR" describe --tags --always)

    info "Versao atual: $VERSION"
    info "Codigo atualizado"

}

update_dependencies() {

    info "Atualizando dependencias Python"

    sudo -u "$APP_USER" "$CRAFTY_DIR/venv/bin/pip" install -r "$CRAFTY_DIR/requirements.txt"

    info "Dependencias atualizadas"

}

fix_permissions() {

    info "Ajustando permissoes"

    chown -R "$APP_USER:$APP_USER" "$APP_DIR"

    info "Permissoes ajustadas"

}

start_service() {

    info "Iniciando servico Crafty"

    systemctl start "$SERVICE_NAME"

    info "Servico iniciado"

}

show_access_url() {

    IP=$(hostname -I | awk '{print $1}')

    echo
    echo "=========================================="
    echo "Atualizacao concluida com sucesso"
    echo
    echo "Acesse o Crafty em:"
    echo
    echo "https://${IP}:8443"
    echo "=========================================="

}

main() {

    echo "=========================================="
    echo "   $APP_NAME Updater"
    echo "=========================================="
    echo

    check_root
    check_installation
    stop_service
    update_code
    update_dependencies
    fix_permissions
    start_service
   show_access_url

}

main