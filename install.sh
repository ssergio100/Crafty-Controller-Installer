#!/bin/bash

set -e

# ==========================================
# Crafty Installer
# ==========================================

APP_NAME="Crafty Controller"
APP_USER="crafty"
APP_DIR="/opt/crafty"

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
        error "Este instalador precisa ser executado como root. Use: sudo ./install.sh"
    fi
}

check_dependencies() {

    info "Verificando dependencias"

    local packages=(
        python3
        python3-venv
        python3-pip
        git
        curl
    )

    local missing=()

    for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        info "Instalando dependencias faltantes:"
        printf '%s\n' "${missing[@]}"

        apt update
        apt install -y "${missing[@]}"
    else
        info "Todas as dependencias ja estao instaladas"
    fi
}

create_user() {

    info "Verificando usuario $APP_USER"

    if id "$APP_USER" >/dev/null 2>&1; then
        info "Usuario $APP_USER ja existe"
    else
        info "Criando usuario $APP_USER"

        useradd \
            --system \
            --create-home \
            --home-dir "$APP_DIR" \
            --shell /bin/bash \
            "$APP_USER"

        info "Usuario $APP_USER criado"
    fi
}

create_directories() {

    info "Criando estrutura de diretorios"

    local directories=(
        "$APP_DIR"
        "$APP_DIR/app"
        "$APP_DIR/config"
        "$APP_DIR/backups"
        "$APP_DIR/logs"
        "$APP_DIR/servers"
    )

    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            info "Criado: $dir"
        fi
    done

    chown -R "$APP_USER:$APP_USER" "$APP_DIR"

    info "Permissoes ajustadas para $APP_USER"
}

run_as_crafty() {
    sudo -u "$APP_USER" "$@"
}

download_crafty() {

    info "Obtendo codigo do Crafty"

    local CRAFTY_DIR="$APP_DIR/app/crafty"

    if [ -d "$CRAFTY_DIR/.git" ]; then
        info "Repositorio ja existe. Atualizando..."

        run_as_crafty git -C "$CRAFTY_DIR" pull

    else
        info "Clonando repositorio do Crafty..."

        mkdir -p "$APP_DIR/app"

        run_as_crafty git clone \
            https://gitlab.com/crafty-controller/crafty-4.git \
            "$CRAFTY_DIR"
    fi

    chown -R "$APP_USER:$APP_USER" "$APP_DIR"

    info "Codigo do Crafty pronto"
}

create_venv() {

    info "Criando ambiente virtual Python"

    local CRAFTY_DIR="$APP_DIR/app/crafty"
    local VENV_DIR="$CRAFTY_DIR/venv"

    if [ -d "$VENV_DIR" ]; then
        info "Ambiente virtual ja existe"
    else
        run_as_crafty python3 -m venv "$VENV_DIR"
        info "Ambiente virtual criado"
    fi
}

install_python_dependencies() {

    info "Instalando dependencias Python"

    local CRAFTY_DIR="$APP_DIR/app/crafty"
    local VENV_DIR="$CRAFTY_DIR/venv"

    if [ ! -f "$CRAFTY_DIR/requirements.txt" ]; then
        error "Arquivo requirements.txt nao encontrado"
    fi

    run_as_crafty "$VENV_DIR/bin/pip" install --upgrade pip

    run_as_crafty "$VENV_DIR/bin/pip" install \
        -r "$CRAFTY_DIR/requirements.txt"

    info "Dependencias Python instaladas"
}

install_systemd_service() {

    info "Configurando servico systemd"

    local SERVICE_FILE="/etc/systemd/system/crafty.service"

    cp "$SCRIPT_DIR/systemd/crafty.service" "$SERVICE_FILE"

    systemctl daemon-reload

    systemctl enable crafty

    info "Servico systemd configurado"
}

start_service() {

    info "Iniciando servico Crafty"

    systemctl start crafty

    sleep 5

    if systemctl is-active --quiet crafty; then
        info "Crafty iniciado com sucesso"
    else
        error "Falha ao iniciar o Crafty. Verifique com: journalctl -u crafty"
    fi
}

verify_installation() {

    info "Validando instalacao"

    if ! systemctl is-active --quiet crafty; then
        error "Servico Crafty nao esta ativo"
    fi

    if ! ss -tulpn | grep -q ":8443"; then
        error "Porta 8443 nao encontrada"
    fi

    info "Servico ativo"
    info "Interface web disponivel"
}


show_summary() {

    local IP=$(hostname -I | awk '{print $1}')

    echo
    echo "=========================================="
    echo " Crafty instalado com sucesso"
    echo "=========================================="
    echo
    echo "Acesse:"
    echo
    echo "https://$IP:8443"
    echo
    echo "Servico:"
    echo "crafty.service"
    echo
    echo "Diretorio:"
    echo "$APP_DIR"
    echo
    echo "=========================================="
}

main() {

    echo "=========================================="
    echo "      $APP_NAME Installer"
    echo "=========================================="
    echo

    info "Diretorio do instalador: $SCRIPT_DIR"
    info "Usuario: $APP_USER"
    info "Instalacao: $APP_DIR"

    check_root
    check_dependencies
    create_user
    create_directories
    download_crafty
    create_venv
    install_python_dependencies
    install_systemd_service
    start_service
    verify_installation
    show_summary
}

main
