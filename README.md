# Iridium

A native GNOME audio tag editor (`co.tylr.Iridium`), written in Vala with
GTK4, libadwaita and Blueprint. Tags are handled by TagLib.

## Prerequisites (Fedora)

One command sets up everything (native build deps + GNOME Flatpak SDK):

```bash
./tools/onboard.sh
```

Opt-ins: `--with-lint` (clang-tidy, vala-lint built from source),
`--with-rpmfusion` (ffmpeg, needed only for test fixtures),
`--with-locales` (French/Spanish/German test locales).
`--check` verifies without changing anything; `--yes` skips prompts.
Other distributions: follow the manual steps in
[02-getting-started](doc/02-getting-started.md) — ports are welcome
(see [contributing requests](doc/11-contributing-requests.md)).

## Build, test, run

```bash
meson setup build && meson compile -C build
meson test -C build
./build/src/iridium
```

Logs: `journalctl --user -t co.tylr.Iridium` (also visible in GNOME Logs).

## Features

- Open files or folders (dialog, drag and drop, command line)
- Edit title, artist, album, genre, year, track, comment
- Show, replace and remove embedded cover art
- Unsaved-change indicator, save and revert
- Journal logging of actions and errors

## Documentation

| Doc | Contents |
|-----|----------|
| [01-overview](doc/01-overview.md) | Stack, scope |
| [02-getting-started](doc/02-getting-started.md) | Dependencies, build, run, Flatpak |
| [03-architecture](doc/03-architecture.md) | Layers, data flow, source map, size rule |
| [04-ui-guide](doc/04-ui-guide.md) | Presentation patterns, adding a component |
| [05-tag-io](doc/05-tag-io.md) | TagLib usage and limits |
| [06-packaging](doc/06-packaging.md) | Flatpak manifest, data files |
| [07-testing-qa](doc/07-testing-qa.md) | Tests, manual checklist |
| [08-contributing](doc/08-contributing.md) | Conventions, PR checklist |
| [09-logging-observability](doc/09-logging-observability.md) | Journal logging, viewing logs |
| [.features](doc/.features/README.md) | Feature plans and status (cover art, batch edit, app icon) |
| [10-test-plan](doc/10-test-plan.md) | Test cases, fixtures, regression list, run log |
| [11-contributing-requests](doc/11-contributing-requests.md) | Help wanted: distro ports, reviews, icon |

## License

GPL-3.0-or-later
