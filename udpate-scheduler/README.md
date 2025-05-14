# Daily Arch Updater

This setup automates daily system updates on Arch Linux (including AUR via `yay`), but **only when connected to a specific WiFi network**.

## Features
- Runs between **9–10 AM daily**
- Checks for a specific WiFi SSID before updating
- Runs in a visible terminal
- Updates both `pacman` and `yay` with `--noconfirm`
- Logs to `/var/log/daily-arch-update.log`

## Usage

1. Edit `script.sh` and set your WiFi name in the `WIFI_NAME` variable.
2. Run the setup:
   ```bash
   chmod +x script.sh
   ./script.sh
