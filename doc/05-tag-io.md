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

The C API exposes only the common fields (no cover art, no per-frame access).
Cover art would need TagLib's complex-property API or the C++ API through a
wrapper; it is out of scope for v0.1.
