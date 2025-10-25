#!/bin/bash

set -e

echo "Starting Arch cleanup..."

# 1. Clean pacman cache, keep only latest packages
echo "Cleaning pacman cache (keeping latest packages)..."
sudo pacman -Syu --noconfirm
sudo paccache -rk1

# 2. Remove orphaned packages
echo "Removing orphaned packages..."
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
  sudo pacman -Rns --noconfirm $orphans
else
  echo "No orphaned packages found."
fi

# 3. Clear user cache (~/.cache)
echo "Clearing user cache (~/.cache)..."
rm -rf ~/.cache/*

# 4. Vacuum system logs older than 7 days
echo "Vacuuming system logs older than 7 days..."
sudo journalctl --vacuum-time=7d

echo "Cleanup completed."
