#!/usr/bin/env bash
#
# my_tools_install.sh - Script para instalar um ambiente de desenvolvimento!
#
# Autor:      Matheus Schwertz
#
# ------------------------------------------------------------------------ #
#  Descrição
#
#  Este script instala as seguintes ferramentas:
#    - kind: Ferramenta para executar clusters Kubernetes locais usando contêineres Docker.
#    - kubectl: Cliente de linha de comando para Kubernetes.
#    - Docker: Plataforma para desenvolver, enviar e executar aplicativos em contêineres.
#    - Terraform: Ferramenta para construir, alterar e versionar infraestrutura de forma eficiente.
#    - AWS CLI: Ela fornece uma interface unificada para gerenciar diversos recursos da AWS.
#    - Git: Sistema de controle de versão distribuído.
#    - Visual Studio Code: Editor de código-fonte.
#    - Vagrant: Ferramenta para criar e gerenciar ambientes de desenvolvimento virtualizados.
#    - VirtualBox: Plataforma de virtualização.
#
#  Exemplos:
#      $ ./my_tools_install_v3.sh
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.1.6
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #

# Verifica se está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root."
   exit 1
fi

# Diretório temporário para downloads
TEMP_DIR=$(mktemp -d)

# Log de instalação
LOG_FILE="install_log.txt"

# Detecta a distribuição
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO=$(uname -s)
fi

# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #

# Esta função instala o 'curl' dependendo da distribuição.
function install_curl () {
  case "$DISTRO" in
    ubuntu) sudo apt install curl -y ;;
    fedora) sudo yum install curl -y ;;
    *) echo "Distribuição não suportada." ;;
  esac
}

# Função para registrar mensagens no log
function log_message() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") $1" >> $LOG_FILE
}

# Esta função instala o 'kind'.
function install_kind () {
  log_message "Instalando kind..."
  curl -Lo $TEMP_DIR/kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x $TEMP_DIR/kind && \
    sudo mv $TEMP_DIR/kind /usr/local/bin/kind
}

# Esta função instala o 'kubectl'.
function install_kubectl() {
  log_message "Instalando kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    sudo mv kubectl /usr/local/bin/kubectl 
}

# Esta função instala o 'Docker'.
function install_docker() {
  log_message "Instalando Docker..."

  # Verifica se o Docker já está instalado
  if command -v docker &> /dev/null; then
      echo "O Docker já está instalado."
      return
  fi

  # Adiciona a chave GPG do Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  # Adiciona o repositório do Docker
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

  # Atualiza os pacotes e instala o Docker
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  # Adiciona o usuário ao grupo docker
  sudo usermod -aG docker $(whoami)

  # Informa que o Docker foi instalado com sucesso
  echo "Docker foi instalado com sucesso."

  # Adiciona o usuário ao grupo docker temporariamente
  newgrp docker

  # Baixa e executa a imagem Alpine
  docker run -it alpine sh
}

function install_terraform() {
  log_message "Instalando Terraform..."
  # Instala o Terraform
  curl -LO "https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip"
  unzip terraform_0.15.5_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
}

# Esta função instala a AWS CLI.
function install_aws_cli() {
  log_message "Instalando AWS CLI..."
  # Baixa o instalador da AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$TEMP_DIR/awscliv2.zip"

  # Descompacta o instalador
  unzip "$TEMP_DIR/awscliv2.zip"

  # Executa o instalador
  sudo "$TEMP_DIR/aws/install"

  # Limpa os arquivos temporários
  rm -rf "$TEMP_DIR/aws" "$TEMP_DIR/awscliv2.zip"
}

# Esta função instala o 'git'.
function install_git() {
  log_message "Instalando Git..."
  case "$DISTRO" in
    ubuntu) sudo apt install git -y ;;
    fedora) sudo yum install git -y ;;
    *) echo "Distribuição não suportada." ;;
  esac
}

# Esta função configura o Git com o nome de usuário e e-mail.
function configure_git() {
  log_message "Configurando Git..."
  git config --global user.name "matheusschertz"
  git config --global user.email "matheusschertz@gmail.com"
}

function install_vscode() {
  log_message "Instalando Visual Studio Code..."

  # Instala o Visual Studio Code
  case "$DISTRO" in
    ubuntu)
      curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > $TEMP_DIR/microsoft.gpg
      sudo install -o root -g root -m 644 $TEMP_DIR/microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
      sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
      sudo apt-get install apt-transport-https
      sudo apt-get update
      sudo apt-get install code
      rm $TEMP_DIR/microsoft.gpg
      ;;
    fedora)
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
      sudo dnf check-update
      sudo dnf install code
      ;;
    *) echo "Distribuição não suportada." ;;
  esac
}

function install_vagrant() {
  log_message "Instalando Vagrant..."

  # Instala o Vagrant
  case "$DISTRO" in
    ubuntu)
      sudo apt update
      sudo apt install vagrant -y
      ;;
    fedora)
      sudo dnf install vagrant -y
      ;;
    *) echo "Distribuição não suportada." ;;
  esac
}

function install_virtualbox() {
  log_message "Instalando VirtualBox..."

  # Instala o VirtualBox
  case "$DISTRO" in
    ubuntu)
      sudo apt update
      sudo apt install virtualbox -y
      ;;
    fedora)
      sudo dnf install VirtualBox -y
      ;;
    *) echo "Distribuição não suportada." ;;
  esac
}

# Função para limpar arquivos temporários
function cleanup_temp() {
  rm -rf "$TEMP_DIR"
}

# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #

# Cria o log de instalação
touch $LOG_FILE

# Verifica se 'curl' está instalado e o instala se não estiver.
[ -z "`which curl`" ] && install_curl
# Verifica se 'kind' está instalado e o instala se não estiver.
[ -z "`which kind`" ] && install_kind
# Verifica se 'kubectl' está instalado e o instala se não estiver.
[ -z "`which kubectl`" ] && install_kubectl
# Verifica se 'docker' está instalado e o instala se não estiver.
[ -z "`which docker`" ] && install_docker
# Verifica se 'terraform' está instalado e o instala se não estiver.
[ -z "`which terraform`" ] && install_terraform
# Verifica se a AWS CLI está instalada e a instala se não estiver.
[ -z "`which aws`" ] && install_aws_cli
# Verifica se 'git' está instalado e o instala se não estiver.
[ -z "`which git`" ] && install_git
# Verifica se 'code' está instalado e o instala se não estiver.
[ -z "`which code`" ] && install_vscode
# Verifica se 'vagrant' está instalado e o instala se não estiver.
[ -z "`which vagrant`" ] && install_vagrant
# Verifica se 'virtualbox' está instalado e o instala se não estiver.
[ -z "`which virtualbox`" ] && install_virtualbox

# Configura o Git
configure_git

# Limpa arquivos temporários
cleanup_temp

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #

# Nada acontece nesta seção. As instalações são feitas nos testes acima.

# ------------------------------------------------------------------------ #
