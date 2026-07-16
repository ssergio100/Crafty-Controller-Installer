#!/bin/bash

APP_DIR="/opt/crafty"
INSTALL_SCRIPT="./install.sh"
UPDATE_SCRIPT="./update.sh"
UNINSTALL_SCRIPT="./uninstall.sh"

info() {
    echo "[INFO] $1"
}

error() {
    echo "[ERRO] $1"
    exit 1
}

check_installation() {

    if [ -d "$APP_DIR/app/crafty" ]; then
        return 0
    else
        return 1
    fi

}
install_menu() {

    echo
    echo "Nenhuma instalacao encontrada."
    echo
    read -rp "Deseja instalar o Crafty? [S/n]: " OPTION

    case "$OPTION" in
        n|N)
            exit 0
            ;;
        *)
            "$INSTALL_SCRIPT"
            ;;
    esac

}

installed_menu() {

    echo
    echo "Instalacao do Crafty encontrada."
    echo
    echo "1) Atualizar"
    echo "2) Remover"
    echo "3) Sair"
    echo

    read -rp "Opcao: " OPTION

    case "$OPTION" in
        1)
            "$UPDATE_SCRIPT"
            ;;
        2)
            "$UNINSTALL_SCRIPT"
            ;;
        *)
            exit 0
            ;;
    esac

}

check_root() {

    if [ "$EUID" -ne 0 ]; then
        error "Execute como root: sudo ./crafty-installer.sh"
    fi

}

main() {

    echo "=========================================="
    echo "   Crafty Controller Installer"
    echo "=========================================="

    check_root

    if check_installation; then
        installed_menu
    else
        install_menu
    fi

}

main