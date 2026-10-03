#!/usr/bin/env bash
# Installs (or removes) the Iridium application.
#
#   tools/install.sh [--flatpak] [--uninstall] [--yes] [--check]
#
# Default: native install from this checkout (meson install + cache updates).
# --flatpak builds a shareable iridium.flatpak bundle and installs it.
# --check reports installed state without changing anything.
set -euo pipefail

YES=0 CHECK=0 FLATPAK=0 UNINSTALL=0
for arg in "$@"; do
    case "$arg" in
        --flatpak) FLATPAK=1 ;;
        --uninstall) UNINSTALL=1 ;;
        --yes) YES=1 ;;
        --check) CHECK=1 ;;
        -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
        *) echo "error: unknown flag $arg (see --help)" >&2; exit 2 ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_ID="co.tylr.Iridium"
BUILD_DIR="$REPO_ROOT/build"
FLATPAK_DIR="$REPO_ROOT/build-flatpak"
BUNDLE="$REPO_ROOT/iridium.flatpak"

say() { printf '%s\n' "$*"; }
confirm() { # confirm <prompt>: true if --yes or user agrees
    if [[ "$YES" == "1" ]]; then
        return 0
    fi
    local ans
    read -rp "$1 [Y/n] " ans
    [[ "${ans:-Y}" =~ ^[Yy]$ ]]
}

native_installed() {
    command -v iridium >/dev/null 2>&1 \
        && [[ -f /usr/local/share/applications/co.tylr.Iridium.desktop ]]
}

flatpak_installed() {
    flatpak info --user "$APP_ID" >/dev/null 2>&1
}

update_caches() {
    update-desktop-database /usr/local/share/applications >/dev/null 2>&1 || true
    gtk-update-icon-cache -f -t /usr/local/share/icons/hicolor >/dev/null 2>&1 || true
}

install_native() {
    for cmd in meson ninja sudo update-desktop-database gtk-update-icon-cache; do
        command -v "$cmd" >/dev/null || { say "error: missing $cmd (run tools/onboard.sh)" >&2; exit 1; }
    done
    if [[ ! -f "$BUILD_DIR/build.ninja" ]]; then
        say "Configuring build/ ..."
        meson setup "$BUILD_DIR" "$REPO_ROOT" >/dev/null
    fi
    say "Compiling ..."
    if ! build_out="$(meson compile -C "$BUILD_DIR" 2>&1)"; then
        grep -E "error:" -A3 <<<"$build_out" | head -20
        exit 1
    fi
    confirm "Install iridium to /usr/local with sudo?" || { say "aborted."; exit 1; }
    sudo meson install -C "$BUILD_DIR" >/dev/null
    update_caches
    native_installed || { say "error: install verification failed" >&2; exit 1; }
    say "Installed: $(command -v iridium)"
}

uninstall_native() {
    if [[ ! -f "$BUILD_DIR/build.ninja" ]]; then
        say "error: no build dir; cannot map installed files (nothing to do)" >&2
        exit 1
    fi
    confirm "Uninstall iridium from /usr/local with sudo?" || { say "aborted."; exit 1; }
    sudo ninja -C "$BUILD_DIR" uninstall >/dev/null
    update_caches
    native_installed && { say "error: still installed after uninstall" >&2; exit 1; }
    say "Uninstalled."
}

install_flatpak() {
    for cmd in flatpak flatpak-builder; do
        command -v "$cmd" >/dev/null || { say "error: missing $cmd (run tools/onboard.sh)" >&2; exit 1; }
    done
    say "Building Flatpak (this takes a while) ..."
    flatpak-builder --force-clean "$FLATPAK_DIR" "$REPO_ROOT/$APP_ID.json"
    say "Exporting bundle $BUNDLE ..."
    rm -f "$BUNDLE"
    flatpak build-bundle "$FLATPAK_DIR" "$BUNDLE" "$APP_ID"
    confirm "Install $APP_ID from bundle for this user?" || { say "aborted."; exit 1; }
    flatpak install --user -y "$BUNDLE"
    flatpak_installed || { say "error: install verification failed" >&2; exit 1; }
    say "Installed: flatpak run $APP_ID"
}

uninstall_flatpak() {
    flatpak_installed || { say "Not installed as a Flatpak (nothing to do)."; exit 0; }
    confirm "Uninstall $APP_ID Flatpak for this user?" || { say "aborted."; exit 1; }
    flatpak uninstall --user -y "$APP_ID"
    say "Uninstalled (bundle file kept at $BUNDLE)."
}

if [[ "$CHECK" == "1" ]]; then
    if [[ "$FLATPAK" == "1" ]]; then
        flatpak_installed && say "INSTALLED: flatpak $APP_ID" || say "MISSING: flatpak $APP_ID"
    else
        native_installed && say "INSTALLED: native iridium ($(command -v iridium))" \
            || say "MISSING: native iridium"
    fi
    [[ -f "$BUNDLE" ]] && say "BUNDLE: $BUNDLE" || say "BUNDLE: none built"
    exit 0
fi

if [[ "$FLATPAK" == "1" ]]; then
    if [[ "$UNINSTALL" == "1" ]]; then uninstall_flatpak; else install_flatpak; fi
else
    if [[ "$UNINSTALL" == "1" ]]; then uninstall_native; else install_native; fi
fi
