# Crafty Controller Installer

Instalador automatizado do Crafty Controller para gerenciamento de servidores Minecraft.

O projeto automatiza a instalação, atualização e remoção do Crafty Controller utilizando:

- usuário dedicado (`crafty`);
- instalação isolada em `/opt/crafty`;
- ambiente virtual Python;
- serviço systemd.

---

# Requisitos

- Linux com systemd
- Acesso root via sudo
- Git
- Python 3

---

# Instalação

Clone o projeto:

```bash
git clone git@github.com:ssergio100/Crafty-Controller-Installer.git
cd Crafty-Controller-Installer
```

Execute o instalador principal:

```bash
sudo ./crafty-installer.sh
```

O instalador verifica automaticamente se já existe uma instalação.

Caso não exista, será oferecida a instalação do Crafty Controller.

---

# Menu principal

Após instalado, execute novamente:

```bash
sudo ./crafty-installer.sh
```

O instalador apresentará as opções disponíveis:

```
1) Atualizar
2) Remover
3) Sair
```

---

# Instalação do Crafty

A instalação realiza:

- criação do usuário de sistema `crafty`;
- criação da estrutura em `/opt/crafty`;
- download do código oficial do Crafty;
- criação do ambiente virtual Python;
- instalação das dependências;
- configuração do serviço systemd;
- inicialização do serviço.

---

# Atualização

A atualização realiza:

- parada do serviço Crafty;
- atualização do código através do Git;
- atualização das dependências Python;
- ajuste das permissões;
- inicialização novamente do serviço.

Ao finalizar, o endereço de acesso ao painel é exibido.

---

# Remoção

A remoção sempre solicita confirmação antes de executar alterações.

Durante o processo é possível escolher entre duas opções.

## Manter servidores Minecraft

Mantém:

```
/opt/crafty/servers
```

Preservando:

- mundos;
- configurações;
- arquivos dos servidores Minecraft.

A aplicação Crafty é removida, mas os dados dos servidores permanecem.

---

## Remover tudo

Remove:

- aplicação Crafty;
- configurações;
- logs;
- backups;
- servidores Minecraft;
- usuário do sistema `crafty`.

Essa opção não pode ser desfeita.

---

# Serviço systemd

O Crafty é executado como serviço:

```bash
systemctl status crafty
```

Comandos disponíveis:

```bash
sudo systemctl start crafty
sudo systemctl stop crafty
sudo systemctl restart crafty
```

---

# Acesso ao painel

Após instalação ou atualização, o painel estará disponível em:

```
https://IP_DO_SERVIDOR:8443
```

---

# Estrutura de diretórios

```
/opt/crafty
├── app
│   └── crafty
├── servers
├── backups
├── logs
└── config
```

---

# Scripts

```
crafty-installer.sh  → menu principal

install.sh           → instalação do Crafty

update.sh            → atualização do Crafty

uninstall.sh         → remoção do Crafty
```

---

# Histórico de versões

## v0.3.0

Adicionado:

- atualização automática do Crafty;
- atualização de dependências Python;
- restauração automática do serviço.

---

## v0.2.0

Adicionado:

- script de remoção;
- confirmação antes da remoção;
- opção de preservar servidores Minecraft.

---

## v0.1.0

Primeira versão funcional:

- instalação completa;
- criação do usuário `crafty`;
- configuração do serviço systemd;
- inicialização automática.