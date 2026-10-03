# Logging and observability

All logging goes through `src/services/app-logger.vala`.

## Where logs go

- Primary: the systemd journal, `SYSLOG_IDENTIFIER=co.tylr.Iridium`, written
  by GLib's journald writer (no libsystemd dependency).
- Fallback: stderr, used when the journal socket is unavailable (e.g. some
  sandboxes). A Flatpak app started from the desktop has stderr captured to
  the journal, so entries still show up.
- When stderr is a terminal, messages are mirrored there during development.

## Levels

| API                           | Level   | Extra fields                |
|-------------------------------|---------|-----------------------------|
| `AppLogger.action(name, d)`   | INFO    | `IRIDIUM_ACTION`            |
| `AppLogger.error(code, m, p)` | WARNING | `CODE`, `IRIDIUM_FILE`      |
| `AppLogger.debug_message(m)`  | DEBUG   | off unless `--verbose` or `G_MESSAGES_DEBUG` |

Messages contain basenames only; full paths are written at DEBUG level.
Actions logged: app-start, app-quit, scan, open-files, open-folder,
drop-files, select, save, revert, cover-change, cover-remove. Errors:
tag-read-failed, tag-save-failed, scan-failed, cover-read-failed,
cover-decode-failed.

## Viewing

```bash
journalctl --user -t co.tylr.Iridium --since -5m
journalctl --user -t co.tylr.Iridium -p warning
./build/src/iridium --verbose
```

GNOME Logs: search for "Iridium" (or `co.tylr.Iridium`).
