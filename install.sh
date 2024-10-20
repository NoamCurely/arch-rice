#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Mettre à jour le système
sudo pacman -Syu

# Vérifier si la mise à jour s'est bien passée
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✔️ Successfully updated the system.${NC}"
else
  echo -e "${RED}❌ An error occurred during the update.${NC}"
  exit 1
fi

# Installation des paquets essentiels via yay
echo -e "${BLUE}Installation des paquets essentiels...${NC}"
yay -S --noconfirm hyprland waybar alacritty base-devel git wayland wayland-protocols libinput wofi swaylock xdg-desktop-portal-hyprland

# Création des dossiers de configuration
echo -e "${BLUE}Création des dossiers de configuration...${NC}"
CONFIG_DIR="$HOME/.config/hypr"
mkdir -p "$CONFIG_DIR"
cp ./config/hyprland/hyprland.conf "$CONFIG_DIR/hyprland.conf"

# Vérifier si le fichier de configuration a été créé
if [ -f "$CONFIG_DIR/hyprland.conf" ]; then
    echo -e "${GREEN}✔️ Hyprland configuration file created successfully.${NC}"
else
    echo -e "${RED}❌ Failed to create Hyprland configuration file.${NC}"
    exit 1
fi

# Optionnel : Démarrer Hyprland (ne pas utiliser exec dans ce contexte si le script est exécuté dans une session Xorg)
echo -e "${GREEN}Installation terminée. Vous pouvez lancer Hyprland manuellement.${NC}"
echo -e "${GREEN}Starting Hyprland...${NC}"
exec Hyprland
