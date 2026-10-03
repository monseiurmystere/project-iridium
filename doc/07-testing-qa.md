# Testing and QA

```bash
meson compile -C build
meson test -C build
```

Tests:
- `tag-roundtrip`: writes and re-reads tags (incl. COMM comment) on a
  synthetic MP3; checks dirty/revert logic; cover round-trip, unloaded-cover
  safety and image limits (`tests/tag-roundtrip.vala`; no GTK needed).
- `validate-desktop`, `validate-metainfo`.

Full manual plan with fixtures: [10-test-plan.md](10-test-plan.md).
Generate fixtures with `tests/fixtures/make-fixtures.sh` (needs ffmpeg).

Manual checklist:
- [ ] Launch with no args: empty state shows
- [ ] Open Files, Open Folder, drag and drop, and `iridium file.mp3` all load files
- [ ] Selecting a file fills the editor; dirty dot and save bar appear on edit
- [ ] Save persists (re-open file); Revert restores
- [ ] Change cover (JPEG/PNG), Remove cover, Save, re-open: cover persists
- [ ] Image over 10 MB or non-image is rejected with a toast
- [ ] Read-only file: error toast + WARNING in journal
- [ ] Narrow window collapses the split view
- [ ] Journal entries appear (see [09-logging-observability.md](09-logging-observability.md))
