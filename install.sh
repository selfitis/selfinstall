#!/bin/bash

# Renklendirme için
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # Renksiz

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}     SelfInstall Auto Install tool     ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Root kontrolü
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}ERROR: RUN THIS SCRIPT WITH 'sudo ./install.sh'.${NC}"
  exit 1
fi

# 1. Gerekli bağımlılıkların (debootstrap) kontrolü
if ! command -v debootstrap &> /dev/null; then
    echo -e "${BLUE}[1/3] debootstrap not found. Installing...${NC}"
    if command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm debootstrap
    else
        echo -e "${RED}ERROR: This install script currently supports only Arch-based systems..${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[1/3] debootstrap already installed.${NC}"
fi

# 2. Debian Kök Klasörünün Hazırlanması
DEBIAN_DIR="/debian-koku"
if [ ! -d "$DEBIAN_DIR" ]; then
    echo -e "${BLUE}[2/3]Creating Debian isolated folder and downloading the base image...${NC}"
    echo -e "${BLUE}(This process may take some time, depending on the internet speed....)${NC}"
    mkdir -p "$DEBIAN_DIR"
    debootstrap stable "$DEBIAN_DIR" http://deb.debian.org/debian/
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Debian base created succesfully!${NC}"
    else
        echo -e "${RED}ERROR: An error occurred while downloading the Debian base..${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[2/3] $DEBIAN_DIR The folder already exists. Skipping this step..${NC}"
fi

# 3. Ana Scriptin Sisteme Kurulması
if [ -f "./selfinstall" ]; then
    echo -e "${BLUE}[3/3] The selfinstall script is being copied to /usr/local/bin/....${NC}"
    cp ./selfinstall /usr/local/bin/selfinstall
    chmod +x /usr/local/bin/selfinstall
    echo -e "${GREEN}The script was successfully copied and authorized..${NC}"
else
    echo -e "${RED}ERROR: The 'selfinstall' file was not found in the same folder!${NC}"
    exit 1
fi

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}🔥 Installation completed successfully! 🔥${NC}"
echo -e "${BLUE}You can now use the 'selfinstall' command.${NC}"
echo -e "${BLUE}Example: selfinstall debian -S mousepad${NC}"
echo -e "${BLUE}==========================================${NC}"
