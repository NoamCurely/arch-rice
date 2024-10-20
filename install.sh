#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Mettre à jour le système
sudo pacman -Syu

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✔️ Successfully updated the system.${NC}"
else
  echo -e "${RED}❌ An error occurred during the update.${NC}"
  exit 1
fi

# Installation des paquets essentiels
echo -e "${BLUE}Installation des paquets essentiels...${NC}"
sudo pacman -S --noconfirm hyprland waybar alacritty picom base-level git wayland wyland-protocols libinput wofi swaylock xdg-desktop-portal-hyprland mesa

# Vérifier les pilotes graphiques
if lspci | grep -q "NVIDIA"; then
    echo -e "${BLUE}Installing NVIDIA drivers...${NC}"
    sudo pacman -S --noconfirm nvidia nvidia-utils
elif lspci | grep -q "AMD"; then
    echo -e "${BLUE}Installing AMD drivers...${NC}"
    sudo pacman -S --noconfirm xf86-video-amdgpu
elif lspci | grep -q "Intel"; then
    echo -e "${BLUE}Installing Intel drivers...${NC}"
    sudo pacman -S --noconfirm mesa
else
    echo -e "${RED}❌ Unknown graphics card. Please install the appropriate drivers manually.${NC}"
    exit 1
fi

# Vérification des permissions d'accès au matériel
if ! groups $USER | grep -q "\<video\>"; then
    echo -e "${BLUE}Adding user to the video group...${NC}"
    sudo usermod -aG video $USER
    echo -e "${GREEN}✔️ User added to video group. Please log out and log back in.${NC}"
fi

# Vérification des variables d'environnement
echo -e "${BLUE}Setting up environment variables...${NC}"
{
    echo "export WAYLAND_DISPLAY=wayland-0"
    echo "export XDG_SESSION_TYPE=wayland"
} >> ~/.bashrc

# Création des dossiers de configuration
CONFIG_DIR="$HOME/.config/hypr"
mkdir -p "$CONFIG_DIR"
cp /usr/share/hyprland/hyprland.conf "$CONFIG_DIR/hyprland.conf"

# Vérifier si le fichier de configuration a été créé
if [ -f "$CONFIG_DIR/hyprland.conf" ]; then
    echo -e "${GREEN}✔️ Hyprland configuration file created successfully.${NC}"
else
    echo -e "${RED}❌ Failed to create Hyprland configuration file.${NC}"
    exit 1
fi

# Démarrer Hyprland (optionnel)
echo -e "${GREEN}Starting Hyprland...${NC}"
exec Hyprland
