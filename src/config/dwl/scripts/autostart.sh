#!/bin/sh

# Notifications
dunst &

# Foot terminal server
foot --server &

# Wallpaper
wbg "$HOME/.local/share/bg" &

# Check pacman updates
pacman -Sy &

pipewire &

gammastep &

wl-paste --watch clipman store &

# Status bar
killall someblocks
# someblocks | "$HOME/.config/dwl/scripts/wl-set-status" &


