# Code tour

How a file gets from disk to screen and back. Layers are described in
[03-architecture.md](03-architecture.md); this is the call-by-call path with
entry points. Line numbers are approximate — grep the symbol if one drifted.

## 1. Startup: `main.vala` → `application.vala`

- `src/main.vala:2` builds `Iridium.Application` and runs it.
- `src/application.vala:33` (`startup`): locale init for translations,
  UTF-8 ID3v2 default, `app.about` / `app.quit` actions with accelerators,
  and the `app-start` journal entry.
- `--verbose` is consumed earlier (`on_local_options`), so the logger is
  already installed when startup logs.

## 2. Opening: three doors, one funnel

- CLI / Open-With: `src/application.vala:65` (`open`) → `Window.add_files`
  (`src/views/iridium-window.vala:57`).
- Dialogs: `win.open-files` / `win.open-folder` → `pick_input`, which wraps
  `src/dialogs/open-dialogs.vala` (empty result on dismiss, never an error).
- Drag and drop: `on_drop` on the window decodes the `Gdk.FileList` and calls
  the same `add_files`.

## 3. Scan: `FileScanner.scan` → store → rows

- `src/services/file-scanner.vala:27`: folders are walked breadth-first into
  local paths; each is read via `TagReader.read` and appended as an
  `AudioFile`. Paths already in the store are skipped (no duplicates); bad
  files are counted and logged, never thrown.
- The loop yields to the main loop every 25 files so large folders do not
  freeze the window.
- New rows appear through the `SidebarView` factory
  (`src/views/sidebar-view.vala`): setup creates a `FileListRow`, bind points
  it at the file, unbind releases it. Row labels are live property bindings
  (`src/views/file-list-row.vala`), so later edits repaint rows for free.

## 4. Select: lazy cover, then load

- Selection emits `file_selected` (`src/views/sidebar-view.vala:13`); the
  window's `on_file_selected` (`src/views/iridium-window.vala:96`) runs:
  1. Disconnect/unbind the previous file (stale handlers would drive the
     wrong save bar).
  2. `ensure_cover` (`iridium-window.vala:132`): reads the embedded picture
     once per file and caches it; failures log and cache as "no cover".
  3. `TagEditorView.load` (`src/views/tag-editor-view.vala:31`): fills the
     cover widget and both tag groups under a `loading` guard, so filling
     entries never marks the file dirty.
  4. Binds `AudioFile.dirty` to the save bar and refreshes action state.

## 5. Edit: keystrokes into the working tag

- Any keystroke emits `edited` from the basic or details group; the editor
  `apply()`s both groups into `file.tag`. Property notify recomputes
  `AudioFile.dirty`, which reveals the save bar, lights the row's dirty dot
  and enables Save/Revert — all without a single explicit UI refresh call.

## 6. Save and revert

- `win.save` → `TagWriter.write` (`src/services/tag-writer.vala:10`):
  text fields always, picture only if loaded *and* changed (an unselected
  file's art is never touched). Success calls `mark_saved()`; failure leaves
  the working tag intact so the user can retry.
- `win.revert` restores working state from the snapshots; disk is untouched.
- Every outcome ends as a toast plus a journal entry (`save`,
  `tag-save-failed`, `revert`).

## 7. Cross-cutting

- **Logging** (`src/services/app-logger.vala`): installed once via
  `init` (`app-logger.vala:16`); journal-first with stderr fallback,
  basenames only at INFO and above. See
  [09-logging-observability.md](09-logging-observability.md).
- **About content** (`src/dialogs/about-dialog.vala:43`): JSON from
  GResources, translated after parsing, hardcoded fallback on failure.
- **i18n extraction** (`po/extract-pot.py`): one xgettext run per source kind
  (Vala, generated `.ui`, desktop, metainfo), merged with msgcat. See
  [.features/translations](.features/translations.md).
- **Tests** (`tests/tag-roundtrip.vala`): synthetic MP3s exercise the
  reader/writer, dirty logic, lazy-cover safety and image limits with no GTK.
