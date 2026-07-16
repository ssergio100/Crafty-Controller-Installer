# Crafty Controller Installer

Instalador automatizado do Crafty Controller para servidores Minecraft.

O objetivo deste projeto é permitir uma instalação limpa, reproduzível e fácil de manutenção, evitando uma sequência manual de comandos que pode ser esquecida no futuro.

## Características

* Instalação automatizada do Crafty Controller
* Usuário dedicado (`crafty`)
* Execução via systemd
* Ambiente Python isolado (`venv`)
* Estrutura de diretórios organizada
* Instalação idempotente (pode ser executado novamente sem quebrar a instalação)

---

# Requisitos

Sistema testado:

* Zorin OS 18.1
* Ubuntu 24.04 / derivados

Requisitos mínimos:

* Acesso root via sudo
* Internet disponível
* Python 3
* Git

---

# Instalação

Clone ou copie este projeto para o servidor.

Execute:

```bash
sudo ./install.sh
```

O instalador irá:

1. Verificar permissões administrativas
2. Instalar dependências necessárias
3. Criar o usuário `crafty`
4. Criar a estrutura de diretórios
5. Baixar o código mais recente do Crafty
6. Criar ambiente virtual Python
7. Instalar dependências Python
8. Criar serviço systemd
9. Iniciar o Crafty
10. Validar a instalação

---

# Estrutura criada

## Projeto do instalador

```
crafty-installer/
├── install.sh
├── README.md
└── systemd/
    └── crafty.service
```

## Instalação do Crafty

```
/opt/crafty
├── app
│   └── crafty
│       ├── venv
│       └── código do Crafty
├── config
├── backups
├── logs
└── servers
```

---

# Serviço Systemd

O Crafty é executado como um serviço do sistema:

Nome:

```
crafty.service
```

Comandos úteis:

Ver status:

```bash
systemctl status crafty
```

Reiniciar:

```bash
sudo systemctl restart crafty
```

Ver logs:

```bash
journalctl -u crafty -f
```

---

# Acesso ao painel

Após a instalação, o painel estará disponível em:

```
https://IP_DO_SERVIDOR:8443
```

O Crafty utiliza HTTPS por padrão.

---

# Atualizações

O projeto será evoluído para incluir um script próprio de atualização:

```
update.sh
```

Esse script será responsável por:

* atualizar o código do Crafty;
* atualizar dependências;
* reiniciar o serviço.



Os mundos dos servidores ficam em:

```
/opt/crafty/servers
```

---

# Filosofia do projeto

Este instalador foi criado com os seguintes objetivos:

* Não depender de memória de comandos manuais.
* Manter o sistema organizado.
* Separar aplicação, dados e serviço.
* Facilitar reinstalação e manutenção futura.
* Permitir versionamento do ambiente.

---

# Versão

Atual:

```
0.1
```
