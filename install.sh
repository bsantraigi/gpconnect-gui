#!/usr/bin/env bash
# Installs gpconnect-tray.
#   ./install.sh                 password prompt (cached for a few minutes) when connecting
#   ./install.sh --no-password   connect without a password prompt (active local session only)
set -euo pipefail
cd "$(dirname "$0")"

ALLOW_ACTIVE=auth_admin_keep
[[ "${1:-}" == "--no-password" ]] && ALLOW_ACTIVE=yes

# Use sudo in a terminal, or a graphical polkit prompt otherwise.
if [[ -t 0 ]] || sudo -n true 2>/dev/null; then SUDO=sudo; else SUDO=pkexec; fi

command -v gpclient >/dev/null || { echo "gpclient not found; install GlobalProtect-openconnect first." >&2; exit 1; }

if ! /usr/bin/python3 -c "import gi; gi.require_version('AyatanaAppIndicator3','0.1')" 2>/dev/null &&
   ! /usr/bin/python3 -c "import gi; gi.require_version('AppIndicator3','0.1')" 2>/dev/null; then
  echo "==> Installing AppIndicator GObject bindings"
  $SUDO apt-get install -y gir1.2-ayatanaappindicator3-0.1 gir1.2-notify-0.7
fi

echo "==> Installing privileged helper and polkit policy (needs sudo)"
$SUDO install -Dm755 -o root -g root "$PWD/gpconnect-helper" /usr/local/libexec/gpconnect-tray/gpconnect-helper
sed "s/@ALLOW_ACTIVE@/$ALLOW_ACTIVE/" io.github.gpconnect-tray.policy |
  $SUDO install -Dm644 -o root -g root /dev/stdin /usr/share/polkit-1/actions/io.github.gpconnect-tray.policy

echo "==> Installing tray app for $USER"
install -Dm755 gpconnect-tray "$HOME/.local/bin/gpconnect-tray"
install -Dm644 gpconnect-tray.desktop "$HOME/.local/share/applications/gpconnect-tray.desktop"
sed -i "s|^Exec=.*|Exec=$HOME/.local/bin/gpconnect-tray|" "$HOME/.local/share/applications/gpconnect-tray.desktop"

mkdir -p "$HOME/.config/autostart"
if [[ ! -e "$HOME/.config/autostart/gpconnect-tray.desktop" ]]; then
  sed "s|^Exec=.*|Exec=$HOME/.local/bin/gpconnect-tray|" gpconnect-tray.desktop \
    > "$HOME/.config/autostart/gpconnect-tray.desktop"
fi

echo
echo "Done. Launch \"GlobalProtect VPN\" from the app menu, or run: gpconnect-tray &"
echo "It will also start automatically at login (toggle in Settings)."
