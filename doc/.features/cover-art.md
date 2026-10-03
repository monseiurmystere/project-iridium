# Cover art

**Status:** Done (v0.2).

## Goal
Show, replace and remove the embedded front cover of the selected file.

## Decisions
- Read the cover when a file is selected, not at scan time.
- Front cover only (fall back to the first picture).
- Reject images over 10 MB; write the original bytes unchanged.
- Change and Remove buttons only; no drag and drop.

## Design
- TagLib's complex-properties API (`PICTURE` key, TagLib >= 2.0) works across
  MP3 (APIC), FLAC and MP4. Both reading and writing go through a small C
  helper (`src/c/taglib-picture.c`, bound by `src/vapi/iridium-taglib.vapi`),
  because the picture macro and nested pointer arrays are awkward from Vala.
  Saving a cover replaces all pictures in the file with one front cover.
- `CoverArt` model: bytes + MIME type; equality by size and hash.
- `AudioFile` holds the lazily loaded cover (`cover_loaded`, `cover`,
  `saved_cover`). `dirty` = tag dirty or cover dirty. `TagWriter` touches the
  picture only if the cover was loaded and changed.
- `CoverArtService` validates an image file (MIME sniff, size limit).
- `CoverArtWidget` (Gtk.Picture + Change/Remove buttons) is display-only; the
  buttons trigger `win.change-cover` / `win.remove-cover`. The editor hosts it
  in a group at the top.
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
