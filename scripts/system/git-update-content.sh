#!/bin/bash

#==================================
# Source utilities
#==================================
. "$HOME/.dotfiles/scripts/utils/utils.sh"

main() {
  ssh -t git@github.com &>/dev/null

  if [ $? -ne 1 ]; then
    $HOME/.dotfiles/scripts/system/git-set-ssh-key.sh || return 1
  fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  print_in_purple "\n • update content\n\n"

  ask_for_confirmation "do you want to update the content from the 'dotfiles' directory?"

  if answer_is_yes; then
    git fetch --all 1>/dev/null &&
      git reset --hard origin/main 1>/dev/null &&
      git checkout main &>/dev/null &&
      git clean -fd 1>/dev/null

    print_result $? "update content"
  fi
}

main
