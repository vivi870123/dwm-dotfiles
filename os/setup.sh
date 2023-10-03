#!/bin/bash

declare -r GITHUB_REPOSITORY="vivi870123/dotfiles"
declare -r DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"
declare -r DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/main"
declare -r DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/main/os/utils.sh"

declare dotfilesDirectory="$HOME/.dotfiles"
declare skipQuestions=false

# ----------------------------------------------------------------------
# | Helper Functions                                                   |
# ----------------------------------------------------------------------

download() {
  local url="$1"
  local output="$2"

  if command -v "curl" &>/dev/null; then
    curl -LsSo "$output" "$url" &>/dev/null
    return $?
  elif command -v "wget" &>/dev/null; then
    wget -qO "$output" "$url" &>/dev/null
    return $?
  fi

  return 1
}

download_dotfiles() {
  local tmpFile=""
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  print_in_purple "\n • Download and extract archive\n\n"

  tmpFile="$(mktemp /tmp/XXXXX)"

  download "$DOTFILES_TARBALL_URL" "$tmpFile"
  print_result $? "Download archive" "true"
  printf "\n"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if ! $skipQuestions; then
    ask_for_confirmation "Do you want to store the dotfiles in '$dotfilesDirectory'?"

    if ! answer_is_yes; then
      dotfilesDirectory=""
      while [ -z "$dotfilesDirectory" ]; do
        ask "Please specify another location for the dotfiles (path): "
        dotfilesDirectory="$(get_answer)"
      done
    fi

    # Ensure the `dotfiles` directory is available
    while [ -e "$dotfilesDirectory" ]; do
      ask_for_confirmation "'$dotfilesDirectory' already exists, do you want to overwrite it?"
      if answer_is_yes; then
        rm -rf "$dotfilesDirectory"
        break
      else
        dotfilesDirectory=""
        while [ -z "$dotfilesDirectory" ]; do
          ask "Please specify another location for the dotfiles (path): "
          dotfilesDirectory="$(get_answer)"
        done
      fi
    done

    printf "\n"
  else
    rm -rf "$dotfilesDirectory" &>/dev/null
  fi

  mkdir -p "$dotfilesDirectory"
  print_result $? "Create '$dotfilesDirectory'" "true"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Extract archive in the `dotfiles` directory.

  extract "$tmpFile" "$dotfilesDirectory"
  print_result $? "Extract archive" "true"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  rm -rf "$tmpFile"
  print_result $? "Remove archive"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd "$dotfilesDirectory/os" || return 1
}

download_utils() {
  local tmpFile=""
  tmpFile="$(mktemp /tmp/XXXXX)"

  download "$DOTFILES_UTILS_URL" "$tmpFile" &&
    . "$tmpFile" &&
    rm -rf "$tmpFile" &&
    return 0

  return 1
}

extract() {
  local archive="$1"
  local outputDir="$2"

  if command -v "tar" &>/dev/null; then
    tar -zxf "$archive" --strip-components 1 -C "$outputDir"
    return $?
  fi

  return 1
}

verify_os() {
  declare -r MINIMUM_FEDORA_VERSION="6"
  local os_name
  local os_version

  os_name="$(get_os)"
  os_version="$(get_os_version)"

  echo  $os_version

  # Check if the OS is one of the linux variant` and
  if [ "$os_name" == "manjaro" ]; then
	  return 0
  elif [ "$os_name" == "fedora" ]; then
	  return 0
  else
	  printf "Sorry, this script is intended only for macOS and Linux !"
  fi

  return 1
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------
main() {
	# Ensure that the following actions
	# are made relative to this file's path.
	cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Load utils
  if [ -x "utils.sh" ]; then
	  . "utils.sh" || exit 1
  else
	  download_utils || exit 1
  fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Ensure the OS is supported and
  # it's above the required version.
  # verify_os || exit 1

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  skip_questions "$@" && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  ask_for_sudo

  # Check if this script was run directly (./<path>/setup.sh),
  # and if not, it most likely means that the dotfiles were not
  # yet set up, and they will need tohmyzshohmyzsho be downloaded.
  # printf "%s" "${BASH_SOURCE[0]}" | grep "setup.sh" \  &>/dev/null || download_dotfiles

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   ./shell/create_directories.sh

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   ./shell/create_symbolic_links.sh

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # ./shell/git_create_local_config.sh

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # change shell to zsh
  # chsh -s "$(which zsh)"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # ./fedora/main.sh

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # if cmd_exists "git"; then
    # if [ "$(git config --get remote.origin.url)" != "$DOTFILES_ORIGIN" ]; then
      # ./shell/git_initialize_repository.sh "$DOTFILES_ORIGIN"
    # fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # if ! $skipQuestions; then
      # ./shell/git_update_content.sh
    # fi
  # fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # if ! $skipQuestions; then
    # ./shell/restart.sh
  # fi
}

main @