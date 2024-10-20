#!/bin/bash

# Vérifier si l'utilisateur est root (nécessaire pour l'installation)
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script en tant que root (avec sudo)." 
  exit 1
fi

# Fonction pour vérifier si un paquet est installé, sinon l'installer
install_if_missing() {
  if ! pacman -Qi "$1" &>/dev/null; then
    echo "Installation de $1..."
    pacman -S --noconfirm "$1"
  else
    echo "$1 est déjà installé."
  fi
}

# Mise à jour du système
echo "Mise à jour du système..."
pacman -Syu --noconfirm

# Installer les prérequis
echo "Installation des prérequis..."
install_if_missing base-devel
install_if_missing git

# Installation des paquets nécessaires avec pacman
echo "Installation des paquets essentiels..."
pacman -S --noconfirm hyprland waybar terminator neofetch cava tela-circle-icon-theme catppuccin-gtk-theme-mocha rofi swaybg wofi noto-fonts noto-fonts-emoji ttf-iosevka-nerd

# Création des dossiers de configuration si besoin
echo "Création des dossiers de configuration..."
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/terminator ~/.config/neofetch ~/Images/wallpapers

# Copie du fond d'écran (remplace par le tien ou modifie le chemin)
echo "Copie du fond d'écran..."
wget -O ~/Images/wallpapers/default_wallpaper.png https://source.unsplash.com/random/1920x1080?nature

# Création de la configuration Hyprland
echo "Création de la configuration Hyprland..."
cat <<EOF > ~/.config/hypr/hyprland.conf
# Configuration de base Hyprland

# Fond d'écran
exec-once=swaybg -i ~/Images/wallpapers/default_wallpaper.png -m fill

# Layout par défaut
layout=master

# Gaps et comportement
vfriction=0.9
gaps_in=15
gaps_out=30
rounding=10

# Lancer Waybar et Terminator au démarrage
exec-once=waybar
exec-once=terminator

# Bindings clavier
bind=SUPER+Return, exec, terminator
bind=SUPER+d, exec, wofi --show drun
EOF

# Création de la configuration Waybar
echo "Création de la configuration Waybar..."
cat <<EOF > ~/.config/waybar/config
{
  "layer": "top",
  "height": 30,
  "modules-left": ["network", "cpu"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "battery"],
  "cpu": {
    "interval": 5,
    "format": "{usage}%"
  },
  "clock": {
    "format": "%a %b %d, %H:%M:%S"
  },
  "battery": {
    "format": "{capacity}%"
  },
  "pulseaudio": {
    "format": "{volume}%"
  },
  "network": {
    "format": "{ifname} {ipaddr}"
  }
}
EOF

cat <<EOF > ~/.config/waybar/style.css
* {
  font-family: "Iosevka Nerd Font", sans-serif;
  font-size: 12px;
  color: #ffffff;
  background-color: #282c34;
}

#clock {
  background-color: #44475a;
  padding: 5px;
  border-radius: 5px;
}

#battery {
  color: #ff5555;
}

#cpu {
  color: #8be9fd;
}
EOF

# Création de la configuration Neofetch
echo "Création de la configuration Neofetch..."
cat <<EOF > ~/.config/neofetch/config.conf
print_info() {
    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "Resolution" resolution
    info "WM" wm
    info "CPU" cpu
    info "Memory" memory
    info "GPU" gpu
}
EOF

# Création de la configuration Terminator
echo "Création de la configuration Terminator..."
cat <<EOF > ~/.config/terminator/config
[global_config]
  title_transmit_bg_color = "#2d2d2d"
  title_inactive_bg_color = "#3c3c3c"

[profiles]
  [[default]]
    use_system_font = False
    font = Iosevka Nerd Font 12
    scrollback_infinite = True
    background_color = "#282c34"
    foreground_color = "#ffffff"
    cursor_color = "#ff79c6"
    use_custom_command = True
    custom_command = neofetch
EOF

# Script de démarrage pour lancer les applications au lancement d'Hyprland
echo "Création du script de démarrage..."
cat <<EOF > ~/.config/hypr/launch.sh
#!/bin/bash
# Lancer Waybar
waybar &
# Lancer Terminator
terminator &
EOF

chmod +x ~/.config/hypr/launch.sh

# Ajouter le script de lancement à la configuration Hyprland
echo "Ajout du script de lancement à la configuration Hyprland..."
echo "exec-once=~/.config/hypr/launch.sh" >> ~/.config/hypr/hyprland.conf

# Fin de l'installation
echo "Installation terminée ! Déconnectez-vous et connectez-vous avec Hyprland pour voir les changements."
