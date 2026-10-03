# Packaging

`co.tylr.Iridium.json` builds `blueprint-compiler`, TagLib 2.0.2 (pinned
sha256) and Iridium against `org.gnome.Platform`.

- Permissions: Wayland/X11 fallback, IPC, DRI, `xdg-music` read/write. Other
  folders go through the file portal (`Gtk.FileDialog`).
- Data files in `data/`: desktop entry, metainfo, icon. Validated by
  `meson test`.
- Before publishing: bump the runtime version, add screenshots to the
  metainfo, replace the placeholder icon.
