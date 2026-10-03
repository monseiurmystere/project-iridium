# Tag I/O

Tags are read and written through TagLib's C API. Vala ships a binding
(`taglib_c.vapi`), so no custom vapi is needed; meson uses
`dependency('taglib_c')`.

- `TagReader.read(path)` -> `AudioTag` (throws `TagError.OPEN`)
- `TagWriter.write(audio_file)` writes all fields then `mark_saved()`
  (throws `TagError.OPEN` / `TagError.SAVE`)
- ID3v2 default encoding is set to UTF-8 at startup (`application.vala`).
- Strings returned by TagLib are copied immediately, then
  `TagLib.Tag.free_strings()` is called.
- Scanned extensions: mp3, flac, ogg, oga, opus, m4a (`file-scanner.vala`).

## Cover art

Covers use TagLib's complex-property API (`PICTURE`, TagLib >= 2.0) through
`src/c/taglib-picture.c` and `src/vapi/iridium-taglib.vapi`.

- Read lazily when a file is selected (`TagReader.read_cover`); the first
  embedded picture is shown.
- Saving a changed cover replaces all pictures with a single front cover; an
  unloaded or unchanged cover is never written (`AudioFile.cover_changed`).
- `CoverArtService.load` accepts JPEG/PNG up to 10 MB, bytes kept as-is.
- Formats that reject pictures fail the save with an error toast.
- Other per-frame access is not exposed.
