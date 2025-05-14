#!/bin/bash

# === USER CONFIGURATION ===
WIFI_NAME="AirFiber-ru4eeW"  # <-- Replace this with your actual WiFi SSID
# ===========================

SCRIPT_PATH="/usr/local/bin/daily-arch-update"
SERVICE_PATH="/etc/systemd/system/daily-arch-update.service"
TIMER_PATH="/etc/systemd/system/daily-arch-update.timer"
LOG_FILE="/var/log/daily-arch-update.log"

echo "Creating update script at $SCRIPT_PATH..."

sudo tee "$SCRIPT_PATH" > /dev/null <<EOF
#!/bin/bash

TARGET_SSID="$WIFI_NAME"
LOG_FILE="$LOG_FILE"

CURRENT_SSID=\$(iwgetid -r)

if [ "\$CURRENT_SSID" != "\$TARGET_SSID" ]; then
    echo "\$(date): Not on \$TARGET_SSID. Skipping update." >> "\$LOG_FILE"
    exit 1
fi

TERMINAL=\$(command -v gnome-terminal xfce4-terminal konsole xterm | head -n1)

if [ -z "\$TERMINAL" ]; then
    echo "\$(date): No terminal emulator found." >> "\$LOG_FILE"
    exit 1
fi

echo "\$(date): Connected to \$CURRENT_SSID. Running full system update." >> "\$LOG_FILE"
\$TERMINAL -- bash -c 'sudo pacman -Syu --noconfirm && yay -Syu --noconfirm; sleep 5' >> "\$LOG_FILE" 2>&1
EOF

echo "Making script executable..."
sudo chmod +x "$SCRIPT_PATH"

echo "Creating systemd service file..."
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Run daily Arch + AUR update if on correct WiFi

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

echo "Creating systemd timer file..."
sudo tee "$TIMER_PATH" > /dev/null <<EOF
[Unit]
Description=Run Arch update once a day between 9 and 10 AM

[Timer]
OnCalendar=*-*-* 09:00:00
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "Reloading systemd daemon and enabling timer..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now daily-arch-update.timer

echo "✅ Setup complete!"
echo "Timer status:"
systemctl list-timers | grep daily-arch-update
