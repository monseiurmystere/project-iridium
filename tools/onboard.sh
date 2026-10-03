#!/usr/bin/env bash
# First-time contributor setup for Iridium (Fedora only).
#
#   tools/onboard.sh [--yes] [--check] [--with-lint] [--with-rpmfusion] [--with-locales]
#
# Default: native build/test dependencies + GNOME Flatpak SDK.
# --check verifies without changing anything (exit 0 = ready, 1 = gaps).
set -euo pipefail

YES=0 CHECK=0 LINT=0 RPMFUSION=0 LOCALES=0
for arg in "$@"; do
    case "$arg" in
        --yes) YES=1 ;;
        --check) CHECK=1 ;;
        --with-lint) LINT=1 ;;
        --with-rpmfusion) RPMFUSION=1 ;;
        --with-locales) LOCALES=1 ;;
        -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
        *) echo "error: unknown flag $arg (see --help)" >&2; exit 2 ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "fedora" && "${ID_LIKE:-}" != *fedora* ]]; then
    echo "error: this script supports Fedora only (found ${ID:-unknown})." >&2
    echo "Follow the manual steps in README.md, or port this script:" >&2
    echo "see doc/.features/portable-onboarding.md." >&2
    exit 2
fi

BASE_PKGS=(vala meson ninja-build gcc gtk4-devel libadwaita-devel
    blueprint-compiler taglib-devel json-glib-devel gettext
    desktop-file-utils appstream flatpak-builder ffmpeg-free)
# Encoders the fixture script needs. Fedora's ffmpeg-free qualifies.
NEEDED_ENCODERS=(libmp3lame aac flac libopus)
LINT_PKGS=(clang-tools-extra libvala-devel)
LOCALE_PKGS=(glibc-langpack-fr glibc-langpack-es glibc-langpack-de)
VALA_LINT_TAG="0.1.0"
VALA_LINT_REPO="https://github.com/vala-lang/vala-lint.git"

# Runtime versions come from the Flatpak manifest, never hardcoded here.
RUNTIME="$(python3 -c "import json; print(json.load(open('$REPO_ROOT/co.tylr.Iridium.json'))['runtime'] + '//' + json.load(open('$REPO_ROOT/co.tylr.Iridium.json'))['runtime-version'])")"
SDK="org.gnome.Sdk//${RUNTIME#*//}"

missing_dnf=()
check_pkgs() { # check_pkgs <array...>: resets and records missing entries
    missing_dnf=()
    local pkg
    for pkg in "$@"; do
        rpm -q "$pkg" >/dev/null 2>&1 || missing_dnf+=("$pkg")
    done
}

gaps=0
say() { printf '%s\n' "$*"; }
need() { # need <label>: records a gap in --check mode
    say "MISSING: $*"
    gaps=$((gaps + 1))
}

say "== base build dependencies =="
check_pkgs "${BASE_PKGS[@]}"
if [[ "${#missing_dnf[@]}" -gt 0 ]]; then
    if [[ "$CHECK" == "1" ]]; then
        need "dnf packages: ${missing_dnf[*]}"
    else
        if [[ "$YES" == "0" ]]; then
            read -rp "Install with sudo dnf (${missing_dnf[*]})? [Y/n] " ans
            [[ "${ans:-Y}" =~ ^[Yy]$ ]] || { say "aborted."; exit 1; }
        fi
        sudo -v
        sudo dnf install -y "${missing_dnf[@]}"
        missing_dnf=()
    fi
else
    say "OK: base packages present"
fi

say "== GNOME Flatpak SDK ($RUNTIME) =="
if ! flatpak remote-list --user 2>/dev/null | grep -q flathub; then
    if [[ "$CHECK" == "1" ]]; then
        need "flathub remote"
    else
        flatpak remote-add --user --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo
    fi
fi
for ref in "$RUNTIME" "$SDK"; do
    if flatpak info --user "$ref" >/dev/null 2>&1; then
        say "OK: $ref"
    elif [[ "$CHECK" == "1" ]]; then
        need "flatpak $ref"
    else
        flatpak install --user -y flathub "$ref"
    fi
done

if [[ "$LINT" == "1" ]]; then
    say "== lint tools =="
    check_pkgs "${LINT_PKGS[@]}"
    if [[ "${#missing_dnf[@]}" -gt 0 ]]; then
        if [[ "$CHECK" == "1" ]]; then
            need "dnf packages: ${missing_dnf[*]}"
        else
            sudo -v
            sudo dnf install -y "${missing_dnf[@]}"
            missing_dnf=()
        fi
    fi
    if command -v io.elementary.vala-lint >/dev/null || [[ -x "$HOME/.local/bin/io.elementary.vala-lint" ]]; then
        say "OK: vala-lint"
    elif [[ "$CHECK" == "1" ]]; then
        need "vala-lint (build from $VALA_LINT_REPO tag $VALA_LINT_TAG)"
    else
        src="$(mktemp -d)/vala-lint"
        git clone -q --branch "$VALA_LINT_TAG" --depth 1 "$VALA_LINT_REPO" "$src"
        meson setup "$src/build" "$src" --prefix="$HOME/.local" >/dev/null
        meson compile -C "$src/build" >/dev/null
        meson install -C "$src/build" >/dev/null
        say "OK: vala-lint installed to ~/.local/bin (ensure it is on PATH)"
    fi
fi

say "== ffmpeg encoder support (fixtures) =="
ffmpeg_has_encoders() {
    command -v ffmpeg >/dev/null || return 1
    local encoders enc
    # Capture first: grep -q closes the pipe early, tripping pipefail via SIGPIPE.
    encoders="$(ffmpeg -hide_banner -encoders 2>/dev/null)"
    for enc in "${NEEDED_ENCODERS[@]}"; do
        grep -q "$enc" <<<"$encoders" || return 1
    done
}
if ffmpeg_has_encoders; then
    say "OK: ffmpeg (system encoders verified)"
elif [[ "$RPMFUSION" == "1" ]]; then
    say "== RPM Fusion fallback: full ffmpeg =="
    if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
        if [[ "$CHECK" == "1" ]]; then
            need "rpmfusion-free-release"
        else
            sudo -v
            sudo dnf install -y \
                "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
        fi
    fi
    if [[ "$CHECK" == "0" ]]; then
        sudo -v
        sudo dnf install -y ffmpeg
        ffmpeg_has_encoders || { say "GAP: RPM Fusion ffmpeg still lacks encoders"; exit 1; }
        say "OK: ffmpeg (RPM Fusion encoders verified)"
    fi
elif [[ "$CHECK" == "1" ]]; then
    need "ffmpeg with encoders: ${NEEDED_ENCODERS[*]} (--with-rpmfusion for the fallback)"
else
    say "GAP: system ffmpeg lacks encoders (${NEEDED_ENCODERS[*]}); re-run with --with-rpmfusion"
    exit 1
fi

if [[ "$LOCALES" == "1" ]]; then
    say "== translation testing locales =="
    check_pkgs "${LOCALE_PKGS[@]}"
    if [[ "${#missing_dnf[@]}" -gt 0 ]]; then
        if [[ "$CHECK" == "1" ]]; then
            need "dnf packages: ${missing_dnf[*]}"
        else
            sudo -v
            sudo dnf install -y "${missing_dnf[@]}"
            missing_dnf=()
        fi
    else
        say "OK: langpacks"
    fi
fi

if [[ "$CHECK" == "1" ]]; then
    if [[ "$gaps" == "0" ]]; then
        say "READY: everything requested is installed."
    else
        say "$gaps gap(s). Re-run without --check to install."
        exit 1
    fi
    exit 0
fi

say "== verification =="
for pc in gtk4 libadwaita-1 taglib_c json-glib-1.0; do
    pkg-config --exists "$pc" && say "OK: pkg-config $pc" || { say "GAP: $pc"; exit 1; }
done
for cmd in meson valac blueprint-compiler flatpak-builder; do
    command -v "$cmd" >/dev/null && say "OK: $cmd" || { say "GAP: $cmd"; exit 1; }
done
say "Done. Next: meson setup build && meson compile -C build && meson test -C build"
