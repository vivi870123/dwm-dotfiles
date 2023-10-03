#!/bin/bash

#==================================
# Variables
#==================================
declare GITHUB_REPOSITORY="vivi870123/dotfiles"
declare DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"
declare DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/main"
declare DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/main/scripts/utils/utils.sh"

#==================================
# Settings
#==================================
declare DOTFILES_DIR="$HOME/.dotfiles"
declare MINIMUM_ARTIX_VERSION="6.4.12"

declare skipQuestions=false

#==================================
# Helper Functions
#==================================
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

  print_title "Download and extract archive"
  tmpFile="$(mktemp /tmp/XXXXX)"

  download "$DOTFILES_TARBALL_URL" "$tmpFile"
  print_result $? "Download archive" "true"

  mkdir -p "$DOTFILES_DIR"
  print_result $? "Create '$DOTFILES_DIR'" "true"

  # Extract archive in the `dotfiles` directory.
  extract "$tmpFile" "$DOTFILES_DIR"
  print_result $? "Extract archive" "true"

  rm -rf "$tmpFile"
  print_result $? "Remove archive"
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
  local os_name="$(get_os)"
  local os_version="$(get_os_version)"

  # Check if the OS is `Fedora` and supported
  if [ "$os_name" == "fedora" ]; then
    if is_supported_version "$os_version" "$MINIMUM_UBUNTU_VERSION"; then
      print_success "$os_name $os_version is supported"
      return 0
    else
      print_error "Minimum Ubuntu $MINIMUM_UBUNTU_VERSION is required (current is $os_version)"
    fi
  # Check if the OS is `Artix` and supported
  elif [ "$os_name" == "artix" ]; then
    print_success "$os_name $os_version is supported"
    return 0
  else
    # Exit if not supported OS
    print_error "$os_name is not supported. This dotfiles are intended for MacOS, Ubuntu and Arch"
  fi
  return 1
}

#==================================
# Main Setup
#==================================
main() {
  # Ensure that the following actions are made relative to this file's path.
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

  # Load utils
  if [ -x "utils/utils.sh" ]; then
    . "utils/utils.sh" || exit 1
  else
    download_utils || exit 1
  fi

  print_section "Dotfiles Setup"

  # Ask user for sudo
  print_title "Sudo Access"
  ask_for_sudo

  # Verify OS and OS version
  print_title "Verifying OS"
  verify_os || exit 1

  # Check if this script was run directly (./<path>/setup.sh),
  # and if not, it most likely means that the dotfiles were not
  # yet set up, and they will need to be downloaded.
  # printf "%s" "${BASH_SOURCE[0]}" | grep "setup.sh" &> /dev/null \ || download_dotfiles

  # Start installation
  . "$HOME/.dotfiles/scripts/system/$(get_os)/install.sh"

}

main "$@"
