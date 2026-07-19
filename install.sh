#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== SelfInstall Setup ===${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: Please run this script as root using 'sudo ./install.sh'.${NC}"
  exit 1
fi

# Get the real user details from the host system
REAL_USER=${SUDO_USER:-$USER}
REAL_UID=$(id -u "$REAL_USER")

# 1. debootstrap check
if ! command -v debootstrap &> /dev/null; then
    echo -e "${BLUE}[1/2] Installing debootstrap...${NC}"
    pacman -Sy --noconfirm debootstrap
else
    echo -e "${GREEN}[1/2] debootstrap is already installed.${NC}"
fi

# 2. Creating Debian Directory and Fetching Base System
DEBIAN_DIR="/debian-koku"
if [ ! -d "$DEBIAN_DIR" ]; then
    echo -e "${BLUE}[2/2] Downloading clean Debian base system...${NC}"
    mkdir -p "$DEBIAN_DIR"
    debootstrap stable "$DEBIAN_DIR" http://deb.debian.org/debian/
    
    # Configure base environment and tools inside chroot
    echo -e "${BLUE}Configuring core system tools and user access...${NC}"
    sudo chroot "$DEBIAN_DIR" env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin apt-get update
    sudo chroot "$DEBIAN_DIR" env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin apt-get install -y passwd sudo locales
    
    # Prevent locale warnings by generating C.UTF-8
    sudo chroot "$DEBIAN_DIR" env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin sed -i 's/# c.UTF-8 UTF-8/c.UTF-8 UTF-8/' /etc/locale.gen
    sudo chroot "$DEBIAN_DIR" env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin locale-gen
    
    # Mirror host system user to prevent permission issues (e.g., Dolphin root block)
    sudo chroot "$DEBIAN_DIR" env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/sbin/useradd -m -u "$REAL_UID" "$REAL_USER"
else
    echo -e "${GREEN}[2/2] $DEBIAN_DIR already exists. Skipping bootstrap.${NC}"
fi

# 3. Deploy selfinstall binary globally
if [ -f "./selfinstall" ]; then
    cp ./selfinstall /usr/local/bin/selfinstall
    chmod +x /usr/local/bin/selfinstall
    echo -e "${GREEN}SUCCESS: selfinstall is now available globally!${NC}"
else
    echo -e "${RED}Error: 'selfinstall' file not found in current directory!${NC}"
    exit 1
fi
