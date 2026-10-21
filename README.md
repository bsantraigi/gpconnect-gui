# gpconnect-tray

A small system-tray front end for [GlobalProtect-openconnect](https://github.com/yuezk/GlobalProtect-openconnect)
(`gpclient` / `gpauth`). Uses GTK 3 and AppIndicator, so it works in GNOME (Ubuntu),
Cinnamon/MATE/Xfce (Linux Mint), KDE and plain XEmbed trays such as polybar. The tray
icon is a full-colour shield (green connected, amber connecting, grey disconnected)
that stays legible on dark and light panels regardless of the icon theme.

## Install

```sh
./install.sh                # asks for your password when connecting (cached ~5 min)
./install.sh --no-password  # no password prompt for the active local session
```

Then start **GlobalProtect VPN** from the app menu. It also starts at login (toggle it in Settings).

## How it works

Equivalent to `sudo -E gpclient --fix-openssl connect --browser microsoft-edge-stable --disable-ipv6 <portal>`, but split so the browser never runs as root:

1. `gpauth --fix-openssl --browser=microsoft-edge-stable <portal>` runs **as you** and opens Edge for SSO.
2. The resulting cookie is piped to `pkexec gpconnect-helper`, which runs
   `gpclient --fix-openssl connect --disable-ipv6 --browser=microsoft-edge-stable --auto-gateway --cookie-on-stdin <portal>` as root (the `--browser` is used for the second, gateway login).
3. Choosing **Disconnect** (or quitting the tray) tells the helper to stop gpclient.

If a tunnel was started from a terminal instead, the icon still shows it as connected, and Disconnect runs `pkexec gpclient disconnect`.

- Left-click (or right-click on GNOME): menu. Middle-click: connect/disconnect.
- Settings: portal, browser, gateway (empty = `--auto-gateway`), IPv6, OpenSSL mode, autostart, auto-connect.
- Config: `~/.config/gpconnect-tray/config.json`

## Troubleshooting

**Browser says "Authentication Complete" but the tray keeps waiting.** The browser hands the
sign-in back through a `globalprotectcallback:` link that `xdg-open` passes to `gpgui.desktop`.
GlobalProtect-openconnect 3.x ships `Exec="/usr/bin/gpclient" launch-gui %u`. Outside GNOME/KDE
(e.g. i3), xdg-utils 1.1.x does not strip those quotes and fails silently (`Permission denied`).
The tray writes a user-level `~/.local/share/applications/gpgui.desktop` with an unquoted `Exec`
before every connect. To check by hand:

```sh
xdg-open globalprotectcallback:test   # good: "No external-browser authentication is waiting…"
                                      # bad:  "xdg-open: …: Permission denied"
```

## Uninstall

```sh
./uninstall.sh
```
