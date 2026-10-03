# Cover art

**Status:** In progress.

## Goal
Show, replace and remove the embedded front cover of the selected file.

## Decisions
- Read the cover when a file is selected, not at scan time.
- Front cover only (fall back to the first picture).
- Reject images over 10 MB; write the original bytes unchanged.
- Change and Remove buttons only; no drag and drop.

## Design
- TagLib's complex-properties API (`PICTURE` key, TagLib >= 2.0) works across
  MP3 (APIC), FLAC and MP4. Reading uses a Vala vapi
  (`src/vapi/taglib_complex.vapi`); writing uses a small C helper
  (`src/c/taglib-picture.c`) because the picture macro cannot be called from Vala.
- `CoverArt` model: bytes + MIME type; equality by size and hash.
- `AudioFile` holds the lazily loaded cover (`cover_loaded`, `cover`,
  `saved_cover`). `dirty` = tag dirty or cover dirty. `TagWriter` touches the
  picture only if the cover was loaded and changed.
- `CoverArtService` validates an image file (MIME sniff, size limit).
- `CoverArtWidget` (Gtk.Picture + Change/Remove) emits `cover_changed`; the
  editor hosts it in a group at the top.
- Logging: `cover-change`, `cover-remove` (INFO); `cover-read-failed` (WARNING).

## Steps
1. Binding (vapi + C helper)
2. Model (`CoverArt`, `AudioFile` changes)
3. Reader/writer + `CoverArtService`
4. Round-trip tests
5. Widget
6. Image picker dialog
7. Editor and window wiring
8. Docs

## Risks
- Three-level pointers from TagLib: covered by the round-trip test.
- Formats that reject pictures: save fails with a toast, file stays dirty.
- Memory: only the selected file's cover is loaded.
