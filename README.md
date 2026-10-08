# gpconnect-tray

A small system-tray front end for [GlobalProtect-openconnect](https://github.com/yuezk/GlobalProtect-openconnect)
(`gpclient` / `gpauth`). Uses GTK 3, AppIndicator and your icon theme's standard VPN
icons, so it blends into GNOME (Ubuntu), Cinnamon/MATE/Xfce (Linux Mint) and KDE.

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

## Uninstall

```sh
./uninstall.sh
```
