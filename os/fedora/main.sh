#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "../utils.sh" && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\nInstallation\n\n"

set_dnf_configs() {
  print_in_purple "  • Set DNF configs\n"

  execute "echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf" "Set fastest mirror"
  execute "echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf" "Increase maximum parallel downloads"
  execute "echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf" "set deltarpm to true"
}

set_dnf_configs

update
upgrade

./app.sh

./cleanup.sh
