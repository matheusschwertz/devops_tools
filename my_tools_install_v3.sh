#!/usr/bin/env bash
#
# kind-install.sh - Script para instalar ferramentas relacionadas ao Kubernetes (kind, kubectl, Docker, Git)
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
#    - AWS CLI: 
#    - Git: Sistema de controle de versão distribuído.
#
#  Exemplos:
#      $ ./kind-install.sh
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.1.6
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #

# Não há variáveis definidas nesse script.

# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #

# Esta função obtém o nome da distribuição do sistema.
function get_distro () {
  grep ^ID= /etc/os-release | cut -d  = -f 2
}

# Esta função instala o 'curl' dependendo da distribuição.
function install_curl () {
  case "`get_distro`" in
    ubuntu) sudo apt install curl -y ;;
    fedora) sudo yum install curl -y ;;
  esac
}

# Esta função instala o 'kind'.
function install_kind () {
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    sudo mv ./kind /usr/local/bin/kind
}

# Esta função instala o 'kubectl'.
function install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    sudo mv kubectl /usr/local/bin/kubectl 
}

# Esta função instala o 'Docker'.
function install_docker() {
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
  # Instala o Terraform
  curl -LO "https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip"
  unzip terraform_0.15.5_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
}

# Esta função instala a AWS CLI.
function install_aws_cli() {
  # Baixa o instalador da AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

  # Descompacta o instalador
  unzip awscliv2.zip

  # Executa o instalador
  sudo ./aws/install

  # Limpa os arquivos temporários
  rm -rf aws awscliv2.zip
}

# Esta função instala o 'git'.
function install_git() {
  case "`get_distro`" in
    ubuntu) sudo apt install git -y ;;
    fedora) sudo yum install git -y ;;
  esac
}

# Esta função configura o Git com o nome de usuário e e-mail.
function configure_git() {
  git config --global user.name "matheusschertz"
  git config --global user.email "matheusschertz@gmail.com"
}

# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #

# Verifica se 'curl' está instalado e o instala se não estiver.
[ -z "`which curl`" ]    && install_curl
# Verifica se 'kind' está instalado e o instala se não estiver.
[ -z "`which kind`" ]    && install_kind
# Verifica se 'kubectl' está instalado e o instala se não estiver.
[ -z "`which kubectl`" ] && install_kubectl
# Verifica se 'docker' está instalado e o instala se não estiver.
[ -z "`which docker`" ]  && install_docker
# Verifica se 'terraform' está instalado e o instala se não estiver.
[ -z "`which terraform`" ] && install_terraform
# Verifica se a AWS CLI está instalada e a instala se não estiver.
[ -z "`which aws`" ] && install_aws_cli
# Verifica se 'git' está instalado e o instala se não estiver.
[ -z "`which git`" ] && install_git

# Configura o Git
configure_git

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #

# Nada acontece nesta seção. As instalações são feitas nos testes acima.

# ------------------------------------------------------------------------ #
