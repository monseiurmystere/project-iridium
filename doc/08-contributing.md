# Contributing

- Follow the size rule and layering in [03-architecture.md](03-architecture.md).
- No business logic in views; no widget code in services.
- Log user actions with `AppLogger.action`, failures with `AppLogger.error`
  and surface failures as toasts.
- Add new framework-free code to `core_sources` and cover it in `tests/`.
- Before a PR: `meson compile`, `meson test`, manual checklist in
  [07-testing-qa.md](07-testing-qa.md).
- New features start as a file in [.features](.features/README.md).
- Icons and raster images must follow the GNOME design language (see
  [app-icon](.features/app-icon.md)).
