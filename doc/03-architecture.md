# Architecture

## Layers

```
views/ + widgets/ + dialogs/   GTK widgets (Passive View)
        | signals / actions
Window (iridium-window)        owns ListStore<AudioFile>, wires everything
        | calls
services/                      FileScanner, TagReader, TagWriter, AppLogger
        | uses
models/                        AudioFile, AudioTag (plain GObjects)
```

Views never call TagLib. Services never touch widgets.

## Data flow

1. Open (dialog / drop / CLI) -> `Window.add_files`
2. `FileScanner.scan` walks folders, `TagReader.read` -> `AudioFile`s appended to the store
3. `SidebarView` shows the store; selection emits `file_selected`
4. `Window` calls `TagEditorView.load(file)`; field edits write live into `file.tag`
5. `AudioFile.dirty` = working tag differs from `saved` snapshot; drives the
   dirty dot, `SaveBar`, and `win.save`/`win.revert` enabled state
6. Save -> `TagWriter.write` -> `file.mark_saved()`

## File size rule

`.vala` <= ~200 lines, `.blp` <= ~150 lines, one widget per file. Split
before exceeding.

## Source map

```
src/main.vala, application.vala    entry, Adw.Application, app actions, accels
src/models/                        audio-tag, audio-file, cover-art
src/services/                      app-logger, tag-error, tag-reader, tag-writer,
                                   file-scanner, cover-art-service
src/c/, src/vapi/                  TagLib picture helper and its Vala binding
data/about.json                    About dialog strings (GResource, parsed with json-glib)
src/views/                         window, empty-state, sidebar, file-list-row,
                                   tag-editor, tag-basic-group, tag-details-group, save-bar
src/widgets/                        tag-field-row (Adw.EntryRow + uint helpers),
                                   cover-art-widget
src/dialogs/                       about (content from data/about.json, hardcoded
                                   fallback), open-dialogs (Gtk.FileDialog wrappers)
```

`models/` and `services/` are in `core_sources` (src/meson.build), which the
unit tests compile without GTK.
