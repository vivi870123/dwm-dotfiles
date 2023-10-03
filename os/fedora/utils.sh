#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

autoremove() {
  # Remove packages that were automatically installed to satisfy
  # dependencies for other packages and are no longer needed.
  execute "sudo dnf autoremove -qy" "DNF (autoremove)"
}

install_package() {
  declare -r EXTRA_ARGUMENTS="$3"
  declare -r PACKAGE="$2"
  declare -r PACKAGE_READABLE_NAME="$1"

  execute "sudo dnf install -qy $EXTRA_ARGUMENTS $PACKAGE" "$PACKAGE_READABLE_NAME"
}

package_is_installed() {
  dpkg -s "$1" &>/dev/null
}

update() {
  # Resynchronize the package index files from their sources.
  execute "sudo dnf update -qy" "DNF (update)"
}

upgrade() {
  # Install the newest versions of all packages installed.
  execute "sudo dnf upgrade -qy" "DNF (upgrade)"
}
