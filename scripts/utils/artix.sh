#!/bin/bash

#==================================
# SOURCE UTILS
#==================================
cd "$(dirname "${BASH_SOURCE[0]}")" && . "utils.sh"

#==================================
# PACMAN
#==================================
pacman_install() {
	declare -r EXTRA_ARGUMENTS="$3"
	declare -r PACKAGE="$2"
	declare -r PACKAGE_READABLE_NAME="$1"

	if ! pacman_installed "$PACKAGE"; then
		execute "sudo pacman -S --noconfirm --needed $EXTRA_ARGUMENTS $PACKAGE" "$PACKAGE_READABLE_NAME"
	else
		print_success "$PACKAGE_READABLE_NAME"
	fi
}

pacman_update() {
	execute \
		"sudo pacman -Syyu" \
		"Pacman Update"
}

pacman_installed() {
	pacman -Q "$1" &>/dev/null
}

aur_install() {
	declare -r PACKAGE="$2"
	declare -r PACKAGE_READABLE_NAME="$1"

	if ! pacman_installed "$PACKAGE"; then
		execute "yay -S --noconfirm $PACKAGE" "$PACKAGE_READABLE_NAME"
	else
		print_success "$PACKAGE_READABLE_NAME"
	fi
}

#==================================
# FLATPAK
#==================================
flatpak_install() {
	declare -r PACKAGE="$2"
	declare -r PACKAGE_READABLE_NAME="$1"

	if ! flatpak_installed "$PACKAGE"; then
		execute "flatpak install -y flathub $PACKAGE" "$PACKAGE_READABLE_NAME"
	else
		print_success "$PACKAGE_READABLE_NAME"
	fi
}

flatpak_installed() {
	flatpak list --columns=name,application | grep -i "$1" &>/dev/null
}

#==================================
# Git
#==================================
git_make_install() {
	export repodir="$HOME/.local/src"
	mkdir -p "$repodir"

	progname="${1##*/}"
	progname="${progname%.git}"
	dir="$repodir/$progname"

	git -C "$repodir" clone --depth 1 --single-branch \
		--no-tags -q "$1" "$dir" ||
		{
			cd "$dir" || return 1
			sudo -u "$name" git pull --force origin master
		}
	cd "$dir" || exit 1
	make >/dev/null 2>&1
	sudo make install >/dev/null 2>&1
	cd /tmp || return 1
}

install_pyenv() {
	if check_directory "$HOME/.pyenv" "pyenv is already installed. Reinstall?"; then
		execute "curl https://pyenv.run | bash" "Install pyenv and friends"
	fi
	symlink "pyenv/pyenv-virtualenv-after.bash" ".pyenv/plugins/pyenv-virtualenv/etc/pyenv.d/virtualenv/after.bash"
}

install_pyenv_python3() {
	local version
	version=$("$HOME/.pyenv/bin/pyenv" install --list | grep '^\s\+3.11.\d' | tail -1 | xargs)
	execute "$HOME/.pyenv/bin/pyenv install --skip-existing $version" "Python $version"
}

create_pyenv_virtualenv() {
	local version
	if [ -f "$HOME/.pyenv/versions/global" ] && ! confirm "Global virtualenv already exists. Reinstall?"; then
		return
	fi
	version=$("$HOME/.pyenv/bin/pyenv" install --list | grep '^\s\+3.11.\d' | tail -1 | xargs)
	execute \
		"$HOME/.pyenv/bin/pyenv virtualenv --force $version global && $HOME/.pyenv/bin/pyenv global global" \
		"Global virtualenv"
}

install_python_package() {
	local msg=${2:-$1}
	execute "PYENV_VERSION=global $HOME/.pyenv/bin/pyenv exec pip install --upgrade $1" "$msg"
}

install_rustup() {
	execute "curl https://sh.rustup.rs -sSf | bash -s - -y --no-modify-path" "Rustup"
}

install_rust_toolchain() {
	local toolchain=$1
	execute "$HOME/.local/share/cargo/bin/rustup update $toolchain" "Rust toolchain ($toolchain)"
}

install_cargo_package() {
	local msg=${2:-$1}
	execute "$HOME/.local/share/cargo/bin/cargo install $1" "$msg"
}

install_crate() {
	local repo=$1
	local name=${repo#*/}
	shift
	execute "curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | \
           bash -s -- --repo $repo --to $HOME/.local/bin --force $*" "$name"
}
