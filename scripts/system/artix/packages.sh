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

print_title "Installing main packages"
pacman_install "polkit" "polkit"                              # "manages user policies."
pacman_install "gnome-keyring" "gnome-keyring"                # serves as the system keyring.
pacman_install "librewolf" "librewolf"                        # "Browser"
pacman_install "bc" "bc"                                      # "is a mathematics language used for the dropdown calculator.
pacman_install "calcurse" "calcurse"                          # terminal-based organizer
pacman_install "libnotify" "libnotify"                        # allows desktop notifications.
pacman_install "dosfstools" "dosfstools"                      # allows your computer to access dos-like filesystems.
pacman_install "exfat-utils" "exfat-utils"                    # allows management of FAT drives.
pacman_install "atool" "atool"                                # manages and gives information about archives.
pacman_install "unzip" "unzip"                                # unzips zips.
pacman_install "ntfs-3g" "ntfs-3g"                            # allows accessing NTFS partitions.
pacman_install "man-db" "man-db"                              # lets you read man pages of programs.
pacman_install "ffmpeg" "ffmpeg"                              # can record and splice video and audio on the command line.
pacman_install "ffmpegthumbnailer" "ffmpegthumbnailer"        # creates thumbnail previews of video files.
pacman_install "mpd-runit" "mpd-runit"                        # is a lightweight music daemon.
pacman_install "mpc" "mpc"                                    # is a terminal interface for mpd.
pacman_install "mpv" "mpv"                                    # is the patrician's choice video player.
pacman_install "ncmpcpp" "ncmpcpp"                            # a ncurses interface for music with multiple formats
pacman_install "mediainfo" "mediainfo"                        # shows audio and video information
pacman_install "newsboat" "newsboat"                          # is a terminal RSS client.
pacman_install "lynx" "lynx"                                  # is a terminal browser
pacman_install "yt-dlp" "yt-dlp"                              # can download any YouTube video (or playlist or channel)
pacman_install "zathura" "zathura"                            # is a pdf viewer with vim-like bindings.
pacman_install "zathura-pdf-mupdf" "zathura-pdf-mupdf"        # allows mupdf pdf compatibility in zathura.
pacman_install "poppler" "poppler"                            # manipulates .pdfs and gives
pacman_install "fzf" "fzf"                                    # is a fuzzy finder tool
pacman_install "eza" "eza"                                    #  A modern replacement for ls (community fork of exa)
pacman_install "bat" "bat"                                    # "can highlight code output and display files
pacman_install "socat" "socat"                                # "multipurpose relay
pacman_install "moreutils" "moreutils"                        # "is a collection of useful unix tools.
pacman_install "wireplumber" "wireplumber"                    # is the audio system.
pacman_install "pipewire-pulse" "pipewire-pulse"              # gives pipewire compatibility with PulseAudio programs.
pacman_install "pulsemixer" "pulsemixer"                      # is an audio controller
pacman_install "imv" "imv"                                    # is a minimalist image viewer.
pacman_install "kitty" "kitty"                                # A modern, hackable, featureful, OpenGL-based terminal emulator
pacman_install "dunst" "dunst"                                # is a suckless notification system.
pacman_install "pass" "pass"                                  # Stores, retrieves, generates, and synchronizes passwords securely
pacman_install "curl" "curl"                                  # command line tool and library for transferring data with URLs
pacman_install "wget" "wget"                                  # Network utility to retrieve files from the Web
pacman_install "pyhton3" "python3"                            #
pacman_install "jq" "jq"                                      # Command-line JSON processor
pacman_install "tmux" "tmux"                                  # Terminal multiplexer
pacman_install "less" "less"                                  # A terminal based program for viewing text files
pacman_install "fd" "fd"                                      # Simple, fast and user-friendly alternative to find
pacman_install "ripgrep" "ripgrep"                            # A search tool that combines the usability of ag with the raw speed of grep
pacman_install "httpie" "httpie"                              # human-friendly CLI HTTP client for the API era
pacman_install "tldr" "tldr"                                  # Command line client for tldr, a collection of simplified and community-driven man pages.
pacman_install "neofetch" "neofetch"                          #  A CLI system information tool written in BASH that supports displaying images.
pacman_install "transmission" "transmission-runit"            # BitTorrent client (CLI tools, daemon and web client)
pacman_install "networkmanager" "networkmanager-runit"        # BitTorrent client (CLI tools, daemon and web client)
pacman_install "gammastep" "gammastep"                        # Adjust the color temperature of your screen according to your surroundings.
pacman_install "bemenu" "bemenu"                              # Dynamic menu library and client program inspired by dmenu
pacman_install "zoxide" "zoxide"                              # A smarter cd command for your terminal
pacman_install "wl-roots" "wl-roots"                          # Modular Wayland compositor library
pacman_install "wtype" "wtype"                                # xdotool for wayland
pacman_install "wl-clipboard" "wl-clipboard"                  # Command-line copy/paste utilities for Wayland
pacman_install "foot" "foot"                                  # Fast, lightweight, and minimalistic Wayland terminal emulator
pacman_install "grim" "grim"                                  # Screenshot utility for Wayland
pacman_install "swappy" "swappy"                              # A Wayland native snapshot editing tool
pacman_install "slurp" "slurp"                                # Select a region in a Wayland compositor
pacman_install "light" "light"                                # Program to easily change brightness on backlight-controllers.
pacman_install "github-cli" "github-cli"                      # Github cli
aur_install "lf-git" "lf-git"                                 # is an extensive terminal file manager that everyone likes.
aur_install "librewolf-bin" "librewolf-bin"                   # is the default browser of LARBS which also comes with ad-blocking and other sensible and necessary features by default.
aur_install "arkenfox-user.js" "arkenfox-user.js"             # provides hardened security settings for Firefox and Librewolf to avoid Mozilla spyware and general web fingerprinting.
aur_install "sc-im" "sc-im"                                   # is an Excel-like terminal spreadsheet manager.
aur_install "abook" "abook"                                   # is an offline addressbook usable by neomutt.
aur_install "task-spooler" "task-spooler"                     # queues commands or files for download.
aur_install "simple-mtpfs" "simple-mtpfs"                     # enables the mounting of cell phones.
aur_install "htop-vim" "htop-vim"                             # is a graphical and colorful system monitor.
aur_install "tremc" "tremc-git"                               # Curses interface for transmission - python3 fork of transmission-remote-cli
aur_install "networkmanager-dmenu" "networkmanager-dmenu-git" # Control NetworkManager via dmenu
aur_install "wbg" "wbg"                                       # Wallpaper application for wlroots based Wayland compositors
aur_install "pamixer" "pamixer"                               # Pulseaudio command-line mixer like amixer
aur_install "clipman" "clipman"                               # A simple clipboard manager for Wayland
aur_install "wl-color-picker" "wl-color-picker"               # A wayland color picker that also works on wlroots
aur_install "wlr-randr" "wlr-randr"                           # Utility to manage outputs of a Wayland compositor

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
