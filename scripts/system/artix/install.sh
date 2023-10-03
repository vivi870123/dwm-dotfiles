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
print_section "Running Artix Dotfiles Setup"

# Setup symlinks
. "$HOME/.dotfiles/scripts/system/symlink.sh"

# Git: Local config
. "$HOME/.dotfiles/scripts/system/git-local-config.sh"

# Setup packages
. "$HOME/.dotfiles/scripts/system/artix/packages.sh"

if cmd_exists "git"; then
  if [ "$(git config --get remote.origin.url)" != "$DOTFILES_ORIGIN" ]; then
    . "$HOME/.dotfiles/scripts/system/git-initialize-repository.sh" "$DOTFILES_ORIGIN"
  fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if ! $skipQuestions; then
    . "$HOME/.dotfiles/scripts/system/git-update-content.sh"
  fi
fi

if ! $skipQuestions; then
  . "$HOME/.dotfiles/scripts/system/artix/restart.sh"
fi
