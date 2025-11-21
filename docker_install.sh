#!/bin/bash
#####################################################
# Guillermo Torres                                  #
# Date: Fri 21 Nov 2025                             #
# Time: 20:45                                       #
# Description: 'Instala docker en el sistema        #
#               dependiendo de si es Arch o Debian' #
# Distribution: Arch Linux                          #
#####################################################
set -e # Fuerza la finalización si algo falla

##### Colores para la salida :) #####
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}--- INSTALACIÓN DE DOCKER ---${NC}"


##### Comprobar el SO #####
if [ -f /etc/os-release ]; then 
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}No se pudo detectar el sistema operativo (/etc/os-release no encontrado).${NC}"
    exit 1
fi

echo -e "${BLUE}Sistema detectado: ${YELLOW}$OS${NC}"

##### Instalación para basados en debian #####
if [[ "$OS" == "debian" || "$OS" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    echo -e "${GREEN}Ejecutando instalación para sistemas basados en Debian/APT...${NC}"
    
    sudo apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    
    DISTRO_URL="debian"
    if [ "$OS" == "ubuntu" ]; then DISTRO_URL="ubuntu"; fi
    
    sudo curl -fsSL "https://download.docker.com/linux/$DISTRO_URL/gpg" -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DISTRO_URL \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

##### Instalación para Arch Linux #####
elif [[ "$OS" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
    echo -e "${GREEN}Ejecutando instalación para Arch Linux...${NC}"
    
    sudo pacman -Syu --noconfirm docker docker-compose docker-buildx

else
    echo -e "${RED}Distribución no soportada por este script automático: $OS${NC}"
    exit 1
fi

echo -e "${CYAN}--- Configuración final ---${NC}"

sudo systemctl enable --now docker

#### AÑADIR EL USUARIO AL GRUPO DOCKER SI NO ESTÁ ####
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi

sudo usermod -aG docker $USER

echo -e "${GREEN}Instalación completada.${NC}"
echo -e "${YELLOW}POR FAVOR: Cierre su sesión y vuelva a entrar (o ejecute 'newgrp docker') para aplicar los cambios de grupo.${NC}"
