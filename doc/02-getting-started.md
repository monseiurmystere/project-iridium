# Getting started

## Dependencies (Fedora)

The scripted path is `./tools/onboard.sh` (see README.md). The manual
equivalent, for other distributions or debugging, is below. Package names are
Fedora's; ports are requested in
[11-contributing-requests](11-contributing-requests.md).

```bash
# Required: build and test.
sudo dnf install vala meson ninja-build gcc gtk4-devel libadwaita-devel \
  blueprint-compiler taglib-devel json-glib-devel gettext desktop-file-utils \
  appstream flatpak-builder

# Lint (clang-tidy) and the vala-lint source build:
sudo dnf install clang-tools-extra libvala-devel
git clone --branch 0.1.0 --depth 1 https://github.com/vala-lang/vala-lint.git
meson setup vala-lint/build vala-lint --prefix=$HOME/.local
meson compile -C vala-lint/build && meson install -C vala-lint/build

# Optional: translation test locales.
sudo dnf install glibc-langpack-fr glibc-langpack-es glibc-langpack-de

# Optional: ffmpeg for test fixtures (needs RPM Fusion, not in Fedora repos).
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install ffmpeg
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

## Translations

```bash
sudo dnf install glibc-langpack-fr glibc-langpack-es glibc-langpack-de  # for testing
meson compile -C build iridium-pot   # regenerate po template after UI changes
for l in fr es de; do msgmerge -U po/$l.po build/po/iridium.pot; done
sudo meson install -C build          # .mo files only load from the installed localedir
LANG=de_DE.UTF-8 iridium
```
