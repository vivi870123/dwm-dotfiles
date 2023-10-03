#!/bin/bash

#==================================
# OS Check
#==================================
get_os() {
  local os=""
  local kernelName=""
  kernelName="$(uname -s)"

  if [ "$kernelName" == "Darwin" ]; then
    os="macos"
  elif [ "$kernelName" == "Linux" ] &&
    [ -e "/etc/os-release" ]; then
    os="$(
      . /etc/os-release
      printf "%s" "$ID"
    )"
  else
    os="$kernelName"
  fi

  printf "%s" "$os"
}

get_os_version() {
  local os=""
  local version=""
  os="$(get_os)"

  if [ "$os" == "macos" ]; then
    version="$(sw_vers -productVersion)"
  elif [ -e "/etc/os-release" ]; then
    version="$(
      . /etc/os-release
      printf "%s" "$VERSION_ID"
    )"
  fi

  printf "%s" "$version"
}

is_supported_version() {
  # shellcheck disable=SC2206
  declare -a v1=(${1//./ })
  # shellcheck disable=SC2206
  declare -a v2=(${2//./ })
  local i=""

  # Fill empty positions in v1 with zeros.
  for ((i = ${#v1[@]}; i < ${#v2[@]}; i++)); do
    v1[i]=0
  done

  for ((i = 0; i < ${#v1[@]}; i++)); do
    # Fill empty positions in v2 with zeros.
    if [[ -z ${v2[i]} ]]; then
      v2[i]=0
    fi

    if ((10#${v1[i]} < 10#${v2[i]})); then
      return 1
    elif ((10#${v1[i]} > 10#${v2[i]})); then
      return 0
    fi
  done
}

#==================================
# Ask
#==================================
ask_for_sudo() {
  print_question "Setup requires sudo access "

  # Ask for the administrator password upfront.
  sudo -v &>/dev/null

  # Update existing `sudo` time stamp
  # until this script has finished.
  #
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &>/dev/null &
}

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] &&
    return 0 ||
    return 1
}

ask() {
  print_question "$1"
  read -r
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -r -n 1
  printf "\n"
}

#==================================
# Misc
#==================================
get_answer() {
  printf "%s" "$REPLY"
}

cmd_exists() {
  command -v "$1" &>/dev/null
}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}

#==================================
# Git
#==================================
is_git_repository() {
  git rev-parse &>/dev/null
}

repo_has_remote_url() {
  git config --get remote.origin.url &>/dev/null
}

#==================================
# Symlink
#==================================

# Create a symlink between two files.
#
# Arguments:
#   $1 the file source relative to the dotfiles directory
#   $2 the file destination relative to the $HOME directory
symlink() {
  local src="$DOTFILES_DIR/$1"
  local dst="$HOME/$2"
  execute "_symlink '$src' '$dst'" "$1 → ~/$2"
}
_symlink() {
  local src=$1
  local dst=$2
  [ -f "$src" ] || { echo "Error: $src does not exist" >&2 && return 1; }
  create_directory "$(dirname "$dst")" || return 1
  ln -fs "$src" "$dst" || return 1
  sleep 0.02
}

# Symlink a Zsh plugin.
#
# Arguments:
#   $1 the file source relative to the dotfiles/zsh/plugins directory.
#   $2 the name of the plugin in the ~/.zsh/plugins directory.
symlink_zsh_plugin() {
  local name=${2:-$1}
  symlink "zsh/plugins/$1.plugin.zsh" ".zsh/plugins/$name.plugin.zsh"
}

# Symlink local/bin file.
#
# Arguments:
#   $1 the file source relative to the dotfiles/local/bin directory.
#   $2 the name of the plugin in the ~/.local/bin directory.
symlink_bin() {
  local name=${2:-$1}
  symlink "src/local/bin/$1" ".local/bin/$name"
}

# Symlink config file.
#
# Arguments:
#   $1 the file source relative to the dotfiles/config directory.
#   $2 the name of the plugin in the ~/.config directory.
symlink_config() {
  local name=${2:-$1}
  execute "ln -fs $DOTFILES_DIR/src/config/$1 $HOME/.config"
}

# Symlink local/share file or dir.
#
# Arguments:
#   $1 the file source relative to the dotfiles/local/share directory.
#   $2 the name of the plugin in the ~/.local/share directory.
symlink_share() {
  local name=${2:-$1}
  symlink "src/local/share/$1" ".local/share/$name"
}

open_dir() {
  # The order of the following checks matters
  if cmd_exists "xdg-open"; then
    xdg-open "$1"
  elif cmd_exists "open"; then
    open "$1"
  else
    print_warning "Can't open $1"
  fi
}

#==================================
# Print
#==================================
print_section() {
  local TITLE="$*"
  local TITLE_LENGTH=${#TITLE}
  local BORDER_LENGTH=$((TITLE_LENGTH + 18))

  local i
  local BANNER_TOP
  for ((i = 0; i < BORDER_LENGTH; ++i)); do
    if [ $i = 0 ]; then
      BANNER_TOP+="╭"
    elif [ $i = $(($BORDER_LENGTH - 1)) ]; then
      BANNER_TOP+="╮"
    else
      BANNER_TOP+="─"
    fi
  done

  local BANNER_BOTTOM
  for ((i = 0; i < BORDER_LENGTH; ++i)); do
    if [ $i = 0 ]; then
      BANNER_BOTTOM+="╰"
    elif [ $i = $(($BORDER_LENGTH - 1)) ]; then
      BANNER_BOTTOM+="╯"
    else
      BANNER_BOTTOM+="─"
    fi
  done

  print_linke_break
  print_in_green "$BANNER_TOP"
  print_in_green "\n│        $TITLE        │\n"
  print_in_green "$BANNER_BOTTOM"
  print_linke_break

}

print_title() {
  print_in_color "\n • $1\n" 5
}

print_success() {
  print_in_green "   [✔] $1\n"
}

print_warning() {
  print_in_yellow "   [!] $1\n"
}

print_error() {
  print_in_red "   [✖] $1 $2\n"
}

print_question() {
  print_in_yellow "   [?] $1"
}

print_option() {
  print_in_yellow "   $1)"
  print_in_white " $2\n"
}

print_result() {
  if [ "$1" -eq 0 ]; then
    print_success "$2"
  else
    print_error "$2"
  fi

  return "$1"
}

print_error_stream() {
  while read -r line; do
    print_error "↳ ERROR: $line"
  done
}

print_in_white() {
  print_in_color "$1" 7
}

print_in_green() {
  print_in_color "$1" 2
}

print_in_purple() {
  print_in_color "$1" 5
}

print_in_red() {
  print_in_color "$1" 1
}

print_in_yellow() {
  print_in_color "$1" 3
}

print_in_blue() {
  print_in_color "$1" 4
}

print_linke_break() {
  printf "\n"
}

print_in_color() {
  printf "%b" \
    "$(tput setaf "$2" 2>/dev/null)" \
    "$1" \
    "$(tput sgr0 2>/dev/null)"
}

#==================================
# Process
#==================================
execute() {

  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

  local exitCode=0
  local cmdsPID=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # If the current process is ended,
  # also end all its subprocesses.

  set_trap "EXIT" "kill_all_subprocesses"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Execute commands in background
  # shellcheck disable=SC2261

  eval "$CMDS" \
    &>/dev/null \
    2>"$TMP_FILE" &

  cmdsPID=$!

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Show a spinner if the commands
  # require more time to complete.

  show_spinner "$cmdsPID" "$CMDS" "$MSG"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Wait for the commands to no longer be executing
  # in the background, and then get their exit code.

  wait "$cmdsPID" &>/dev/null
  exitCode=$?

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Print output based on what happened.

  print_result $exitCode "$MSG"

  if [ $exitCode -ne 0 ]; then
    print_error_stream <"$TMP_FILE"
  fi

  rm -rf "$TMP_FILE"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return $exitCode

}

kill_all_subprocesses() {
  local i=""

  for i in $(jobs -p); do
    kill "$i"
    wait "$i" &>/dev/null
  done
}

set_trap() {
  trap -p "$1" | grep "$2" &>/dev/null ||
    trap '$2' "$1"
}

show_spinner() {
  local -r FRAMES='⡿⣟⣯⣷⣾⣽⣻⢿'

  # shellcheck disable=SC2034
  local -r NUMBER_OR_FRAMES=${#FRAMES}

  local -r CMDS="$2"
  local -r MSG="$3"
  local -r PID="$1"

  local i=0
  local frameText=""

  # Display spinner while the commands are being executed.
  while kill -0 "$PID" &>/dev/null; do
    frameText="   [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"

    # Print frame text.
    printf "%s" "$frameText"
    sleep 0.2
    printf "\r"
  done
}

# Prompt the user with a yes or no question. Times out defaulting to 'No' after
# 10 seconds.
#
# Arguments:
#   $1 the prompt text
#
# Returns:
#   0 if the result was yes
#   1 if the result was no or timed out
confirm() {
  unset USER_ANSWER
  print --color yellow --after 0 --prefix "[?] " --suffix " (y/N) " "$@"
  read -r -n 1 -t 10 USER_ANSWER
  newline
  [[ "$USER_ANSWER" =~ ^[Yy]$ ]]
}

# Check whether a directory exists, and prompt user as to whether we can remove
# it.
check_directory() {
  local directory=$1
  local prompt=$2

  if [ -d "$directory" ]; then
    if confirm "$prompt"; then
      remove_directory "$directory"
      return 0
    fi
  else
    return 0
  fi

  return 1
}

# Removes the given directory.
#
# Arguments:
#   $1 the directory to remove
remove_directory() {
  execute "rm -rf $1" "Remove directory ${1/#$HOME/~}"
}

# Creates the given directory.
#
# Arguments:
#   $1 the directory to create
create_directory() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p '$1'" "Create directory ${1/#$HOME/~}"
    fi
  fi
}
