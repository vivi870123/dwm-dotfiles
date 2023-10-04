#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$HOME/.dotfiles/scripts/utils/utils.sh"
. "$HOME/.dotfiles/scripts/utils/artix.sh"

#==================================
# Print Section Title
#==================================
print_section "Installing Packages"

#==================================
# Install AUR helper
#==================================
print_title "Install AUR Helper"

if ! command -v "yay" &>/dev/null; then
  rm -rf ~/tmp/yay
  execute "git clone --quiet https://aur.archlinux.org/yay.git ~/tmp/yay" "Cloning yay"
  cd ~/tmp/yay || exit
  execute "makepkg -sfci --noconfirm --needed" "Building yay"
fi

#==================================
# Install package managers
#==================================
print_title "Install Flatpak"

if ! command -v "flatpak" &>/dev/null; then
  pacman_install "flatpak" "flatpak"
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1

#==================================
# Install Pacman packages
#==================================

# dmenu clone from suckless

print_title "Installing main packages"

pacman_install "pass" "pass"                                  # Stores, retrieves, generates, and synchronizes passwords securely

pacman_install "jq" "jq"                                      # Command-line JSON processor
pacman_install "tmux" "tmux"                                  # Terminal multiplexer
pacman_install "less" "less"                                  # A terminal based program for viewing text files
pacman_install "fd" "fd"                                      # Simple, fast and user-friendly alternative to find
pacman_install "ripgrep" "ripgrep"                            # A search tool that combines the usability of ag with the raw speed of grep
pacman_install "httpie" "httpie"                              # human-friendly CLI HTTP client for the API era
pacman_install "tldr" "tldr"                                  # Command line client for tldr, a collection of simplified and community-driven man pages.
pacman_install "neofetch" "neofetch"                          #  A CLI system information tool written in BASH that supports displaying images.
pacman_install "transmission" "transmission"            # BitTorrent client (CLI tools, daemon and web client)
pacman_install "zoxide" "zoxide"                              # A smarter cd command for your terminal
pacman_install "github-cli" "github-cli"                      # Github cli

aur_install "tremc" "tremc-git"                               # Curses interface for transmission - python3 fork of transmission-remote-cli
aur_install "networkmanager-dmenu" "networkmanager-dmenu-git" # Control NetworkManager via dmenu
aur_install "pamixer" "pamixer"                               # Pulseaudio command-line mixer like amixer
A, nvm, "Node Version Manager - Simple bash script to manage multiple active node.js versions"


aur_install "arc-gruvbox" "gtk-theme-arc-gruvbox-git"           # dark GTK theme
aur_install "whitesur-icon-theme " "whitesur-icon-theme "       # MacOS Big Sur like icon theme for linux desktops
aur_install "whitesur-cursor-theme" "whitesur-cursor-theme-git" # WhiteSur cursors theme for linux desktops
aur_install "whitesur-gtk-theme" "whitesur-gtk-theme"           # A macOS BigSur-like theme for your GTK apps

print_title "Installing N - node version manager"
export N_PREFIX="$HOME/.local/share/n"
if [ ! -d "$N_PREFIX" ]; then
  execute "curl -L https://bit.ly/n-install | N_PREFIX=$N_PREFIX bash -s -- -y" "Installing N - Node Version Manager"
else
  if command -v n &>/dev/null; then
    print_warning 'n is already installed'
  fi
fi
execute "$HOME/.local/share/n/bin/n stable" "install nvm"

print_title "Rust Development"
create_directory "$HOME/.local/share/cargo"
install_rustup
install_rust_toolchain "stable"
install_crate "rossmacarthur/sheldon"
install_crate "dandavison/delta"

#==================================
# Install Flatpak Packages
#==================================
print_title "Install Flatpak Packages"
flatpak_install "Firefox" "org.mozilla.firefox"
flatpak_install "VsCodeium" "com.vscodium.codium"

#==================================
# Browser Specifics
#==================================
makeuserjs() {
  # Get the Arkenfox user.js and prepare it.
  arkenfox="$pdir/arkenfox.js"
  overrides="$pdir/user-overrides.js"
  userjs="$pdir/user.js"
  ln -fs "$HOME/.config/firefox/mines.js" "$overrides"
  [ ! -f "$arkenfox" ] && curl -sL "https://raw.githubusercontent.com/arkenfox/user.js/master/user.js" >"$arkenfox"
  cat "$arkenfox" "$overrides" >"$userjs"
  # Install the updating script.
  sudo mkdir -p /usr/local/lib /etc/pacman.d/hooks
  sudo cp "$HOME/.local/bin/arkenfox-auto-update" /usr/local/lib/
  sudo chown root:root /usr/local/lib/arkenfox-auto-update
  sudo chmod 755 /usr/local/lib/arkenfox-auto-update
  # Trigger the update when needed via a pacman hook.
  echo "[Trigger]
Operation = Upgrade
Type = Package
Target = firefox
Target = librewolf
Target = librewolf-bin
[Action]
Description=Update Arkenfox user.js
When=PostTransaction
Depends=arkenfox-user.js
Exec=/usr/local/lib/arkenfox-auto-update" | sudo tee /etc/pacman.d/hooks/arkenfox.hook
}

installffaddons() {
  addonlist="ublock-origin decentraleyes istilldontcareaboutcookies vim-vixen"
  addontmp="$(mktemp -d)"
  trap "rm -fr $addontmp" HUP INT QUIT TERM PWR EXIT
  IFS=' '
  mkdir -p "$pdir/extensions/"
  for addon in $addonlist; do
    addonurl="$(curl --silent "https://addons.mozilla.org/en-US/firefox/addon/${addon}/" | grep -o 'https://addons.mozilla.org/firefox/downloads/file/[^"]*')"
    file="${addonurl##*/}"
    curl -LOs "$addonurl" >"$addontmp/$file"
    id="$(unzip -p "$file" manifest.json | grep "\"id\"")"
    id="${id%\"*}"
    id="${id##*\"}"
    mv "$file" "$pdir/extensions/$id.xpi"
  done
  # Fix a Vim Vixen bug with dark mode not fixed on upstream:
  mkdir -p "$pdir/chrome"
  [ ! -f "$pdir/chrome/userContent.css" ] && echo ".vimvixen-console-frame { color-scheme: light !important; }
#category-more-from-mozilla { display: none !important }" | sudo tee "$pdir/chrome/userContent.css"
}

browserdir="$HOME/.librewolf"
profilesini="$browserdir/profiles.ini"

# Start librewolf headless so it generates a profile. Then get that profile in a variable.
librewolf --headless >/dev/null 2>&1 &
sleep 1
profile="$(sed -n "/Default=.*.default-release/ s/.*=//p" "$profilesini")"
pdir="$browserdir/$profile"

# [ -d "$pdir" ] && makeuserjs
# [ -d "$pdir" ] && installffaddons

# Kill the now unnecessary librewolf instance.
pkill librewolf
