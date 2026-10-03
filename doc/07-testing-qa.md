# Testing and QA

```bash
meson compile -C build
meson test -C build
```

Tests:
- `tag-roundtrip`: writes and re-reads tags on a synthetic MP3; checks
  dirty/revert logic (`tests/tag-roundtrip.vala`; no GTK needed).
- `validate-desktop`, `validate-metainfo` (if the tools are installed).

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
