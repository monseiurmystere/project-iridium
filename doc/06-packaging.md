# Packaging

## Installing the app

`tools/install.sh` handles both flavors (`--help`, `--check`, `--yes`
supported throughout):

```bash
./tools/install.sh              # native: compile + sudo meson install
./tools/install.sh --flatpak    # Flatpak: build, bundle, user-install
./tools/install.sh --uninstall  # either flavor (add --flatpak for that one)
```

Native install details:

- Installs to `/usr/local` (`command -v iridium` verifies afterwards).
- Refreshes the desktop database and icon cache, so the launcher entry and
  icon appear immediately (Meson has no `post_install` hooks for these yet).
- Requires an existing `build/` dir or creates one; uninstall needs the same
  build dir to map installed files (`ninja uninstall`).

Flatpak details (`co.tylr.Iridium.json` builds `blueprint-compiler`,
TagLib 2.0.2 pinned by sha256, and Iridium against `org.gnome.Platform`):

- `flatpak-builder --force-clean build-flatpak co.tylr.Iridium.json`, then
  `build-bundle` produces the shareable `iridium.flatpak` (gitignored).
- Installs per-user (`flatpak install --user`); run with
  `flatpak run co.tylr.Iridium`.
- Permissions: Wayland/X11 fallback, IPC, DRI, `xdg-music` read/write. Other
  folders go through the file portal (`Gtk.FileDialog`).

## Data files

`data/`: desktop entry, metainfo, icon, `about.json`. Validated by
`meson test` (`validate-desktop`, `validate-metainfo`, `validate-about-json`).

## Before publishing

Bump the runtime version, add screenshots to the metainfo, replace the
placeholder icon (see [.features/app-icon](.features/app-icon.md)).
