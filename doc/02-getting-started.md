# Getting started

## Dependencies (Fedora)

```bash
sudo dnf install vala meson ninja-build gtk4-devel libadwaita-devel \
  blueprint-compiler taglib-devel desktop-file-utils appstream \
  flatpak-builder
```

## Native build and run

```bash
meson setup build
meson compile -C build
./build/src/iridium            # add --verbose for debug logs
./build/src/iridium song.mp3   # open files directly
```

The binary looks up UI templates from GResources compiled into it, so it runs
from the build directory. The icon appears after `meson install`.

## Tests

```bash
meson test -C build
```

## Flatpak

```bash
flatpak install flathub org.gnome.Platform//49 org.gnome.Sdk//49
flatpak-builder --user --install --force-clean build-flatpak co.tylr.Iridium.json
flatpak run co.tylr.Iridium
```

Check that the runtime version in the manifest is a current GNOME release.
