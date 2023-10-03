#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$HOME/.dotfiles/scripts/utils/utils.sh"
os_name="$(get_os)"

create_symlink() {
  declare -r IS_HIDDEN="$3"
  declare -r DIRECTORY="$2"
  declare -r SYMLINK="$1"

  local sourceFile=""
  local targetFile=""

  sourceFile="$(cd ../../src/ && pwd)/$SYMLINK"

  if $IS_HIDDEN "==" true; then
    targetFile="$DIRECTORY/.$SYMLINK"
  else
    targetFile="$DIRECTORY/$SYMLINK"
  fi

  if [ ! -e "$targetFile" ]; then
    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
  elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
    print_success "$targetFile → $sourceFile"
  else
    ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
    if answer_is_yes; then
      rm -rf "$targetFile"
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    else
      print_error "$targetFile → $sourceFile"
    fi
  fi
}

create_directories() {
  declare -a DIRECTORIES=(
    "$HOME/.ssh"
    "$HOME/.local/bin"
    "$HOME/.local/bin/statusbar"
    "$HOME/.local/share"
    "$HOME/.local/share/lyrics"
    "$HOME/.local/share/mpd"
    "$HOME/.cache/zsh"
    "$HOME/projects"
    "$HOME/projects/laravel"
    "$HOME/Downloads/torrents"
    "$HOME/Pictures/screenshots"
  )

  for i in "${DIRECTORIES[@]}"; do
    mkd "$i"
  done
}

local_bin_symlink() {
  print_title "local symlink"
  declare -a LOCAL_FILES_TO_SYMLINK=(
    "bin/bemenuhandler"
    "bin/bemenumountcifs"
    "bin/bemenupass"
    "bin/bemenurecord"
    "bin/bemenuunicode"
    "bin/booksplit"
    "bin/color-picker"
    "bin/ext"
    "bin/foot-copyout"
    "bin/foot-urlhandler"
    "bin/get_chars"
    "bin/gitbib"
    "bin/getkeys"
    "bin/ifinstalled"
    "bin/linkhandler"
    "bin/lufb"
    "bin/mounter"
    "bin/noisereduce"
    "bin/opout"
    "bin/pauseallmpv"
    "bin/peertubetorrent"
    "bin/podentr"
    "bin/prompt"
    "bin/qndl"
    "bin/queueandnotify"
    "bin/rotdir"
    "bin/rssadd"
    "bin/sd"
    "bin/setbg"
    "bin/shortcuts"
    "bin/slider"
    "bin/sysact"
    "bin/tag"
    "bin/td-toggle"
    "bin/texclear"
    "bin/torwrap"
    "bin/transadd"
    "bin/unix"
    "bin/unmounter"

    "bin/statusbar/sb-battery"
    "bin/statusbar/sb-clock"
    "bin/statusbar/sb-cpu"
    "bin/statusbar/sb-forcast"
    "bin/statusbar/sb-internet"
    "bin/statusbar/sb-memory"
    "bin/statusbar/sb-mpdup"
    "bin/statusbar/sb-music"
    "bin/statusbar/sb-packages"
    "bin/statusbar/sb-torrent"
    "bin/statusbar/sb-volume"

    "share/wallpapers"
    "share/fonts"
    "share/themes"
    "share/mines/chars"
    "share/mines/getkeys"
  )

  for i in "${LOCAL_FILES_TO_SYMLINK[@]}"; do
    create_symlink "$i" "$HOME/.local" false
  done
}

config_symlink() {
  print_title ".config symlink"

  declare -a CONFIG_FILES_TO_SYMLINK=(
    "config/bat"
    "config/bemenu"
    "config/dunst"
    "config/dwl"
    "config/firefox"
    "config/fontconfig"
    "config/foot"
    "config/gammastep"
    "config/git"
    "config/gtk-2.0"
    "config/gtk-3.0"
    "config/htop"
    "config/imv"
    "config/lazygit"
    "config/lf"
    "config/mpd"
    "config/mpv"
    "config/ncmpcpp"
    "config/networkmanager-dmenu"
    "config/newsboat"
    "config/nvim"
    "config/pipewire"
    "config/pulse"
    "config/rg"
    "config/shell"
    "config/swappy"
    "config/tmux"
    "config/wget"
    "config/zathura"
    "config/zsh"
    "config/mimeapps.list"
  )

  for i in "${CONFIG_FILES_TO_SYMLINK[@]}"; do
    create_symlink "$i" "$HOME" true
  done
}

desktop_symlink() {
  execute "rm -rf $HOME/.zshenv"
  execute "rm -rf $HOME/.luarc.json"
  execute "rm -rf $HOME/.gitignore"
  execute "rm -rf $HOME/.stylua.toml"
  execute "rm -rf $HOME/.ignore"
  execute "rm -rf $HOME/.gitconfig"
  execute "rm -rf $HOME/.gitconfig.local"

  execute "ln -sf $DOTFILES/src/config/zsh/zshenv $HOME/.zshenv"
  execute "ln -sf $DOTFILES/src/luarc.json $HOME/.luarc.json"
  execute "ln -sf $DOTFILES/src/gitignore $HOME/.gitignore"
  execute "ln -sf $DOTFILES/src/stylua.toml $HOME/.stylua.toml"
  execute "ln -sf $DOTFILES/src/ignore $HOME/.ignore"
  execute "ln -sf $HOME/.config/dwl/scripts/startw $HOME/.local/bin"
  execute "ln -sf $HOME/.config/git/config $HOME/.gitconfig"
  execute "ln -sf $HOME/.config/git/config.local $HOME/.gitconfig.local"
}

#==================================
# Print Section Title
#==================================
print_section "Creating Symlinks"
create_directories
local_bin_symlink
config_symlink
desktop_symlink
