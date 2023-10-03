#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "../utils.sh" && . "utils.sh"

install_dev_tools() {
  print_in_purple "\n   • Development tools... \n"
  • Set DNF configs
  execute "sudo dnf  groupinstall -qy 'Development Tools' > /dev/null" "Installing development tools"
  install_package "dnf core plugins" "dnf-plugins-core"
  install_package "g++/gcc: Various compilers (C, C++, Objective-C, ...)" "gcc"
  install_package "gcc-c++: C++ support for GCC" "gcc-c++"
  install_package "make: A GNU tool which simplifies the build process for users" "make"
  install_package "cmake: Cross-platform make system" "cmake"
  install_package "autoconf: A GNU tool for automatically configuring source code" "autoconf"
  install_package "automake: A GNU tool for automatically creating Makefiles" "automake"

  install_package "meson: High productivity build system" "meson"
  install_package "wayland-devel: Development files for wayland" "wayland-devel"
  install_package "libxml2: ibraries, includes, etc. to develop XML and HTML applications" "libxml2-devel"
  install_package "libffi: Development files for libffi" "libffi-devel"
  install_package "readline:  Files needed to develop programs which use the readline library" "readline-devel"
  install_package "sqlite: Development tools for the sqlite3 embeddable SQL database engine" "sqlite-devel"
  install_package "ncurses: Development files for the ncurses library" "ncurses-devel"
  install_package "pulseaudio-libs-devel" "pulseaudio-libs-devel"
  install_package "cxxopts-devel" "cxxopts-devel"
  install_package "Font Config" "fontconfig"

  # For Flash Focus
  install_package "libffi devel" "libffi-devel"
  install_package "python devel" "python-devel"
  install_package "python cffi" "python-cffi"
}

enable_rpm_fusion() {
  print_in_purple "\n   • Enable RPM Fusion\n"

  execute "sudo dnf install -qy https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "Enabling rpm fusion free"
  execute "sudo dnf install -qy https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" "Enabling rpm fusion non-free"
}

install_multimedia_codecs() {
  print_in_purple "\n   Installing multimedia codecs... \n"

  execute "sudo dnf groupupdate -y multimedia --setop='install_weak_deps=False' --exclude=PackageKit-gstreamer-plugin --allowerasing" "install codecs"
  execute "sudo dnf groupupdate -y sound-and-video" "sound and video"
  install_package "intel media driver" "intel-media-driver"
}

switch_to_full_ffmpeg() {
  execute "sudo dnf swap ffmpeg-free ffmpeg --allowerasing" "switch to full ffmpeg"
  install_package "mpd" "mpd"
}

install_dnf_packages() {
  print_in_purple "\n   • DNF packages\n"

  install_package "git delta" "git-delta"
  install_package "Kitty Terminal" "kitty"
  install_package "Python" "python3"
  install_package "python3 pip" "python3-pip"
  install_package "luarocks" "luarocks"
  install_package "go" "go"
  install_package "php" "php"
  install_package "composer" "composer"
  install_package "ruby" "ruby"
  install_package "rust" "rust"
  install_package "cargo" "cargo"
  install_package "golang" "go"
  install_package "fontconfig" "fontconfig"

  # install_package "Preload" "preload"
  # sudo dnf copr enable elxreno/preload -y && sudo dnf install preload -y

  # install_package "sed: A GNU stream text editor" "sed"
  # install_package "rsync: A program for synchronizing files over a network" "rsync"
  # install_package "Dev: libbz2" "libbz2-dev"
  execute "sudo dnf copr enable pennbauman/ports -qy" "enabling pennbauman/ports Copr repository"
  install_package "lf" "lf"

  install_package "ffmpegthumbnailer" "ffmpegthumbnailer"
  install_package "gnome-epub-thumbnailer" "gnome-epub-thumbnailer"
  install_package "wkhtmltopdf" "wkhtmltopdf"
  install_package "catdoc (.doc)" "catdoc"
  install_package "odt2txt (optional - for .odt and \*.ods files)" "odt2txt"
  install_package "gnumeric (optional - for .xls and .xlsx files)" "gnumeric"
  install_package "mcomix (optional - for .cbz and .cbr files)" "mcomix3"
  install_package "wob" "wob"
  install_package "fuzzel" "fuzzel"
  install_package "ncmpcpp" "ncmpcpp"
  install_package "nmtui" "NetworkManager-tui"
  install_package "transmission daemon" "transmission-daemon"

  install_package "Wget: A utility for retrieving files using the HTTP or FTP protocols" "wget"
  install_package "Curl: A utility for getting files from remote servers (FTP, HTTP, and others)" "curl"
  install_package "Xclip: Command line clipboard grabber" "xclip"
  install_package "Rg: Line-oriented search tool" "ripgrep"
  install_package "bat: Cat(1) clone with wings" "bat"
  install_package "Libtool" "libtool"
  install_package "thefuck: App that corrects your previous console command" "thefuck"
  install_package "zoxide: Smarter cd command for your terminal" "zoxide"
  install_package "exa: Modern replacement for ls" "exa"
  install_package "unzip: A utility for unpacking zip files" "unzip"
  install_package "unrar: Utility for extracting, testing and viewing RAR archives" "unrar"
  install_package "atool: A perl script for managing file archives of various types" "atool"
  install_package "trash: Command line interface to the freedesktop.org trashcan" "trash-cli"
  install_package "ufw: Uncomplicated Firewall" "ufw"
  install_package "zsh: Powerful interactive shell" "zsh"
  install_package "tmux: A terminal multiplexer" "tmux"
  install_package "sxiv: Simple (or small or suckless) X Image Viewer" "sxiv"
  install_package "newsboat: RSS/Atom feed reader for the text console" "newsboat"
  install_package "mediainfo: Supplies technical and tag information about a video or audio file (CLI)" "mediainfo"
  install_package "mpv: Movie player playing most video formats and DVDs" "mpv"
  install_package "zathura: A lightweight document viewer" "zathura"
  install_package "zathura: pdf plugin support" "zathura-pdf-poppler"
  install_package "highlight: Universal source code to formatted text converter" "highlight"
  install_package "task spooler: Personal job scheduler" "task-spooler"

  install_package "swappy: Wayland native snapshot editing tool, inspired by Snappy on macOS" "swappy"
  install_package "grim: Screenshot tool for Sway" "grim"
  install_package "slurp: Select a region in Sway" "slurp"
  install_package "wl-clipboard: Command-line copy/paste utilities for Wayland" "wl-clipboard"
  install_package "clipman: A simple clipboard manager for Wayland" "clipman"

  install_package "papirus-icon-theme" "papirus-icon-theme"
  install_package "materia-gtk-theme" "materia-gtk-theme"
}

install_VSCode_and_set_inotify_max_user_watches() {
  print_in_purple "\n   Installing VSCode \n"

  if command -v "code" &>/dev/null; then
    print_warning "visual studio code is already installed"
  else
    execute "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc" "import repo"
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    print_in_purple "checking for updates"
    sudo dnf check-update -q &>/dev/null

    install_package "Visual Studio Code" "code"

    execute "echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf" "increase inotify max user watches"
    execute "sudo sysctl -p" "read kernel parameters"
  fi
}

install_google_chrome() {
  print_in_purple "\n   Installing Chrome \n"

  if command -v "google-chrome-stable" &>/dev/null; then
    print_warning "chrome is already installed"
  else
    install_package "fedora workstation repositories" "fedora-workstation-repositories"
    execute "sudo dnf config-manager --set-enabled google-chrome" "Enabling Google Chrome"
    install_package "Google Chrome" "google-chrome-stable"
  fi
}

install_tmux_plugin_manager() {
  print_in_purple "\n   Installing tpm - tmux plugin manager \n"
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    print_warning "tpm is already installed"
  else
    execute "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" "install tmux plugin manager"
  fi
}

install_docker() {
  print_in_purple "\n   Installing docker and enabling its service \n"

  if command -v "docker" &>/dev/null; then
    print_warning "docker is already installed"
  else
    execute "sudo dnf install -qy dnf-plugins-core" "dnf plugins core"
    execute "sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo" "add docker repo"
    execute "sudo dnf makecache" "DNF (makecache)"

    install_package "docker-compose-plugin" "docker-compose-plugin"
    install_package "docker-buildx-plugin" "docker-buildx-plugin"
    install_package "containerd.io" "containerd.io"
    install_package "docker-ce cli" "docker-ce-cli"
    install_package "docker-ce" "docker-ce"
    install_package "Docker compose" "docker-compose"

    execute "sudo systemctl start docker" "systemctl (docker start)"
    execute "sudo systemctl enable docker" "systemctl (docker enable)"
    execute "sudo systemctl status docker" "systemctl (docker status)"

    execute "sudo groupadd docker" "create docker group"
    execute "sudo usermod -aG docker $USER" "add user to docker group"
  fi
}

install_tremc() {
  print_in_purple "\n   Installing tremc \n"

  if command -v "tremc" &>/dev/null; then
    print_warning "tremc is already installed"
  else
    cd "$HOME/Downloads" || print_warning "folder not found"

    tremc_path="$HOME/Downloads/tremc"
    git clone https://github.com/tremc/tremc.git "$tremc_path"
    cd "$tremc_path" || exit 0
    sudo make install
    cd .. || exit 0
    rm -rf "$tremc_path"
  fi
}

install_doc2txt() {
  if command -v "docx2txt.sh" &>/dev/null; then
    print_warning "docx2txt is already installed"
  else
    execute "pip install docx2txt" "installing docx2txt"
  fi
}

install_asdf() {
  print_in_purple "\n   Installing asdf \n"

  if command -v asdf &>/dev/null; then
    print_warning "asdf is already installed"
  else
    asdf_path="$HOME/.local/share/asdf"
    execute "git clone https://github.com/asdf-vm/asdf.git $asdf_path --branch v0.12.0" "clone asdf repo"
    source "$asdf_path/asdf.sh" || print_warning "asdf.sh does not exist"
  fi
}

install_neovim_nightly() {
  print_in_purple "\n   Installing neovim nightly\n"

  if [ ! -d "$HOME/.local/share/asdf" ]; then
    print_warning "asdf is not installed, please install"
  elif command -v nvim &>/dev/null; then
    print_warning "neovim is installed"
  else
    execute "asdf plugin add neovim" "add neovim plugin to asdf"
    print_in_green "Installing neovim nightly"
    asdf install neovim nightly
    execute "asdf global neovim nightly" "setting up neovim for global use"
  fi
}

install_node_version_manager() {
  print_in_purple "\n   Installing N - node version manager \n"
  local N_PREFIX="$HOME/.local/share/n"

  if [ ! -d "$N_PREFIX" ]; then
    execute "curl -L https://bit.ly/n-install | N_PREFIX=$N_PREFIX bash -s -- -y" "Installing N - Node Version Manager"
  else
    if command -v n &>/dev/null; then
      print_warning 'n is already installed'
    fi
  fi
}

# python_package() { }

main() {
  print_in_purple "\n  Main Installation\n"
  install_neovim_nightly
}

main
