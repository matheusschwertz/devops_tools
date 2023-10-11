#!/usr/bin/env bash
#
# kind-install.sh - Breve descrição
#
# Autor:      Matheus Schwertz
#
# ------------------------------------------------------------------------ #
#  Descrição
#
#  Exemplos:
#      $ ./kind-install.sh
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.1.6
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #

# ------------------------------------------------------------------------ #

# ------------------------------- FUNÇÕES ----------------------------------------- #

function get_distro () {
  grep ^ID= /etc/os-release | cut -d  = -f 2
}

function install_curl () {
  
  case "`get_distro`" in
    ubuntu) sudo apt install curl -y ;;
    fedora) sudo yum install curl -y ;;
  esac
}

function install_kind () {
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    sudo mv ./kind /usr/local/bin/kind
}

function install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    sudo mv kubectl /usr/local/bin/kubectl 

}

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

    # Adiciona aqui os comandos que você deseja executar após a mudança de grupo
  echo "Usuário temporariamente no grupo docker."

    # Baixa e executa a imagem Alpine
  docker run -it alpine sh
}


# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #

[ -z "`which curl`" ]    && install_curl
[ -z "`which kind`" ]    && install_kind
[ -z "`which kubectl`" ] && install_kubectl
[ -z "`which docker`" ]  && install_docker

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #

# ------------------------------------------------------------------------ #
