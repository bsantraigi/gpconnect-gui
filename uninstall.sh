#!/usr/bin/env bash
set -euo pipefail
if [[ -t 0 ]] || sudo -n true 2>/dev/null; then SUDO=sudo; else SUDO=pkexec; fi
pkill -f "$HOME/.local/bin/gpconnect-tray" 2>/dev/null || true
rm -f "$HOME/.local/bin/gpconnect-tray" \
      "$HOME/.local/share/applications/gpconnect-tray.desktop" \
      "$HOME/.config/autostart/gpconnect-tray.desktop" \
      "$HOME"/.local/share/icons/hicolor/scalable/status/gpconnect-tray-*.svg
$SUDO rm -rf /usr/local/libexec/gpconnect-tray
$SUDO rm -f /usr/share/polkit-1/actions/io.github.gpconnect-tray.policy
echo "Removed. Settings remain in ~/.config/gpconnect-tray/"
