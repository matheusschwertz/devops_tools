# kind-install.sh

Script para instalar ferramentas relacionadas ao Kubernetes (kind, kubectl, Docker)

## Autor

Matheus Schwertz

## Descrição

Este script instala as seguintes ferramentas:
- kind: Ferramenta para executar clusters Kubernetes locais usando contêineres Docker.
- kubectl: Cliente de linha de comando para Kubernetes.
- Docker: Plataforma para desenvolver, enviar e executar aplicativos em contêineres.
- terraform: Ferramenta para construir, alterar e versionar infraestrutura de forma eficiente.
- aws cli:  

## Testado em

bash 5.1.6

## Pré-requisitos

- Bash 5.1.6 ou superior
- Permissões de administrador para instalar os pacotes

## Instalação

1. Execute o script usando o seguinte comando:

```bash
$ ./kind-install.sh

$ newgrp docker
# devops_tools
