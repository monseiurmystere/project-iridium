# Test plan

Covers Iridium v0.2: file opening, tag editing, save/revert, cover art,
logging. Batch editing is out of scope (see
[.features/batch-edit](.features/batch-edit.md)).

## 1. Conventions

- **IDs are stable.** Never renumber; mark retired cases `Retired:` with a reason.
- **Priority:** P1 = data loss, crash, save correctness. P2 = common flows.
  P3 = polish.
- **Type:** `auto` (runs in `meson test`) or `manual`.
- **Result:** mark `[x]` pass, `[!]` fail (file a defect, section 8), `[-]`
  skipped with a reason.
- **best-effort:** FLAC, M4A and Opus cases are marked **(best-effort)**. A
  failure there does not block a release but must be logged as a defect.
  MP3 cases are required.
- Every logging assertion names the expected `IRIDIUM_ACTION` or `CODE`.
  View logs with `journalctl --user -t co.tylr.Iridium --since -10min`.

## 2. Environment and fixtures

```bash
meson setup build && meson compile -C build
tests/fixtures/make-fixtures.sh /tmp/iridium-fixtures        # needs ffmpeg
tests/fixtures/make-fixtures.sh /tmp/iridium-fixtures --stress  # +500 files
./build/src/iridium
```

| Fixture | Contents |
|---|---|
| `tagged.mp3` | title/artist/album/genre/year/track set (Unicode title), embedded PNG cover |
| `plain.mp3` | no tags, no cover |
| `empty.mp3` | zero bytes |
| `fake.mp3` | text file renamed `.mp3` |
| `truncated.mp3` | valid MP3 cut after 400 bytes |
| `readonly.mp3` | `chmod 444`, no write permission |
| `nested/…` | 3 MP3s two levels deep |
| `images/cover.png`, `cover.jpg` | small valid covers |
| `images/corrupt.png` | truncated PNG (decodes fail) |
| `images/not-image.png` | text file renamed `.png` |
| `images/big.png` | valid PNG magic, just over 10 MB |
| `song.flac`, `song.m4a`, `song.opus` | other formats **(best-effort)** |
| `audio-hashes.txt` | reference audio-stream hashes for DAT cases |

Note: ffmpeg writes the comment as a `TXXX` frame, which TagLib does not
read, so `tagged.mp3` has an empty comment. Setting a comment through the app
writes a real `COMM` frame (covered by `/tag/roundtrip`).

## 3. Automated coverage map

| Test (`meson test`) | Covers |
|---|---|
| `/tag/roundtrip` | SAV-01 core, TAG-01 core (incl. Unicode, COMM comment) |
| `/tag/revert` | SAV-02 core |
| `/cover/roundtrip` | COV-02/03/04/06 core (write, read back, remove, revert) |
| `/cover/unloaded-untouched` | COV-10 core |
| `/cover/service-limits` | COV-07/08 core (type and size rejection) |
| `validate-desktop`, `validate-metainfo`, `validate-about-json` | BLD-02 |
| `po-fr`, `po-es`, `po-de` (`msgfmt --check`) | I18N-07 core (syntax only) |

Everything else is manual.

## 4. App launch (APP)

### APP-01 Launch with no arguments — Priority: P1 — Type: manual — Result: [ ]
Preconditions: no files ever opened (fresh `XDG_CONFIG_HOME` or first run).
Steps: 1. Run `./build/src/iridium`.
Success: empty state shows ("No Files Open", Open Files / Open Folder buttons);
journal has `app-start` with the version.
Failure: crash; main view shown with stale data; no `app-start` entry.

### APP-02 Open file given on the command line — Priority: P1 — Type: manual — Result: [ ]
Preconditions: fixtures generated.
Steps: 1. Run `./build/src/iridium /tmp/iridium-fixtures/tagged.mp3`.
Success: file listed, selected, editor filled; journal has `scan` then `select`.
Failure: empty state; file listed but not selected; crash on missing path
(missing path must be ignored gracefully, not crash).

### APP-03 Debug logging flag — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. Run with `--verbose`. 2. Run without it but with `G_MESSAGES_DEBUG=all`.
Success: full paths appear in the journal only in these runs; hidden otherwise.
Failure: DEBUG lines in a normal run; full home-dir paths at INFO.

### APP-04 Quit — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Quit via the menu. 2. Relaunch, quit via `Ctrl+Q`.
Success: window closes promptly both ways; journal has `app-quit`.
Failure: hang; `app-quit` missing.

### APP-05 About dialog — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. Open menu → About Iridium.
Success: name, version `0.1.0`, developer, GPL-3.0 license shown.
Failure: wrong version; empty fields.

## 5. Opening files (OPN)

### OPN-01 Open Files dialog — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Empty state → Open Files…. 2. Select `tagged.mp3` and `plain.mp3`.
Success: both listed; first file selected; main view replaces empty state;
journal has `open-files` with `count=2` and `scan` with `added=2 failed=0`.
Failure: only one added; empty state remains; counts wrong.

### OPN-02 Open Folder recursively — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Open Folder… → `nested/`.
Success: all 3 nested MP3s listed; journal `open-folder`, `scan added=3`.
Failure: subfolders missed; non-audio files listed.

### OPN-03 Drag and drop — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Drag `tagged.mp3` and `plain.mp3` from Files onto the window.
Success: files added and listed; journal has `drop-files`.
Failure: nothing happens; only the first file added.

### OPN-04 Duplicates are ignored — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open `tagged.mp3`. 2. Open `tagged.mp3` again.
Success: still one row; no second `select`; no error toast.
Failure: duplicate row; tag data reset.

### OPN-05 Unsupported files are skipped — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open `fake.mp3` and `empty.mp3`.
Success: neither listed; error toast per file; journal has `tag-read-failed`
(WARNING) with the basename.
Failure: crash; rows with garbage; no toast; full path in the message.

### OPN-06 Truncated file — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open `truncated.mp3`.
Success: either listed with readable tags, or skipped with toast + log as in
OPN-05. No crash either way.
Failure: crash or hang.

### OPN-07 Large folder stays responsive — Priority: P2 — Type: manual — Result: [ ]
Preconditions: fixtures generated with `--stress`.
Steps: 1. Open Folder… → `stress/` (500 files).
Success: list fills in, window stays responsive throughout; journal `scan
added=500`.
Failure: UI frozen for seconds with no feedback; files missing.

## 6. File list (LST)

### LST-01 Title falls back to filename — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open `plain.mp3`.
Success: row shows `plain.mp3` as the title.
Failure: empty row title.

### LST-02 Artist subtitle — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open `tagged.mp3`.
Success: row shows the title and `Test Artist` underneath.
Failure: subtitle missing or shows the filename.

### LST-03 Dirty dot — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Select `tagged.mp3`. 2. Edit the title. 3. Revert.
Success: record dot appears on edit, disappears on revert; tooltip reads
"Unsaved changes".
Failure: dot stuck on or never appears.

### LST-04 Selection switches the editor — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Open `tagged.mp3` and `plain.mp3`. 2. Click each row.
Success: editor shows the clicked file's tags; cover section updates;
journal has one `select` per click.
Failure: editor shows the wrong file; cover from the previous file lingers.

### LST-05 Row labels update live — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Select `tagged.mp3`. 2. Change title to `ZZZ`, artist to `YYY`.
Success: row updates while typing, without saving.
Failure: row only updates after save; row goes blank on empty title
(must fall back to filename).

## 7. Tag editing (TAG)

### TAG-01 All fields load — Priority: P1 — Type: manual — Result: [ ]
Preconditions: `tagged.mp3` selected.
Success: title `Título Ünïcodé`, artist, album, genre, year `2026`, track
`3` shown; comment empty (see section 2 note).
Failure: any field wrong, empty, or mojibake.

### TAG-02 Edits apply to the working tag — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Change every field. 2. Do NOT save. 3. Reselect the file.
Success: edits intact; dirty dot and save bar visible; no disk write yet
(check `mtime` unchanged).
Failure: edits lost on reselect; file written without Save.

### TAG-03 Year and track accept digits — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Set year `1999`, track `12`. 2. Save, reselect.
Success: values persist; empty input means 0 and shows as empty.
Failure: non-numeric input crashes or saves garbage; 0 displays as "0".

### TAG-04 Clearing a field — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Clear genre. 2. Save, reselect.
Success: genre empty after reload.
Failure: old value restored; save fails on empty strings.

### TAG-05 Unicode round trip — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Set title to `Título Ünïcodé 日本語`. 2. Save, reselect, and check
in another player (`ffprobe`).
Success: identical everywhere.
Failure: mojibake or `?` replacements (would indicate Latin-1 encoding).

### TAG-06 Long strings — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. Paste 500 characters into the title. 2. Save, reselect.
Success: full text persists; editor layout does not break.
Failure: truncation without notice; layout overflow.

### TAG-07 Unsaved edits survive selection switches — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Edit `tagged.mp3` title, don't save. 2. Select `plain.mp3`.
3. Select `tagged.mp3` again.
Success: edit intact, still dirty; `plain.mp3` clean.
Failure: edits leak into the other file; dirty state lost.

### TAG-08 Comment writes a COMM frame — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Set comment to `hello`. 2. Save. 3. Reopen the file in a fresh run.
Success: comment `hello` shown (auto test `/tag/roundtrip` covers the bytes).
Failure: comment lost (would indicate TXXX/COMM mismatch).

## 8. Save and revert (SAV)

### SAV-01 Save persists — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Edit `plain.mp3` title to `Persisted`. 2. Save.
3. Verify with `ffprobe -show_format plain.mp3` and by reopening in the app.
Success: toast `Saved plain.mp3`; dirty dot and save bar clear; value present
in both checks; journal has `save`.
Failure: toast but no write; journal missing; audio hash changed (see DAT-01).

### SAV-02 Revert restores — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Edit title and cover of `tagged.mp3`. 2. Click Revert.
Success: all fields and the cover return to on-disk values; dirty state
clears; journal has `revert`; disk file untouched (`mtime` unchanged).
Failure: any field keeps the edit; cover not restored.

### SAV-03 Actions enable only when dirty — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Select a clean file. 2. Try `Ctrl+S` / `Ctrl+R`. 3. Edit, retry.
Success: Save/Revert disabled when clean (menu and shortcuts do nothing);
enabled when dirty.
Failure: shortcut saves a clean file; buttons never enable.

### SAV-04 Read-only file fails cleanly — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Open `readonly.mp3`. 2. Edit title. 3. Save.
Success: error toast with the reason; file stays dirty with edits intact;
journal has `tag-save-failed` (WARNING).
Failure: silent failure; edits lost; crash.

### SAV-05 Failed save keeps edits — Priority: P1 — Type: manual — Result: [ ]
Covered by SAV-04 on a read-only file; if a second failure mode is found
(full disk, locked file), repeat there.
Success: working tag untouched, still dirty, user can fix and retry.
Failure: editor reset to on-disk state on failure.

## 9. Cover art (COV)

### COV-01 Existing cover displays — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Select `tagged.mp3`.
Success: embedded PNG shown at the top of the editor.
Failure: placeholder shown despite embedded art; stretched/distorted image.

### COV-02 Change cover (JPEG) — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Select `plain.mp3`. 2. Change… → `images/cover.jpg`.
Success: preview updates immediately; dirty dot and save bar appear; journal
has `cover-change`.
Failure: preview stale; no dirty state (change would be lost on switch).

### COV-03 Change cover (PNG) — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Select `plain.mp3`. 2. Change… → `images/cover.png`. 3. Save.
4. Confirm with `ffprobe -show_streams -select_streams v plain.mp3`.
Success: `codec_name=png` stream present; reopening in the app shows it.
Failure: stream missing; wrong MIME; old bytes remain.

### COV-04 Remove cover — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Select `tagged.mp3`. 2. Remove. 3. Save. 4. Reopen.
Success: placeholder shown; dirty until save; no video stream after save;
journal has `cover-remove`.
Failure: cover returns after reopen; Remove does nothing when art exists.

### COV-05 Saved cover visible elsewhere — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. After COV-03, open `plain.mp3` in another player (e.g. GNOME Music,
`ffprobe`).
Success: cover displayed there.
Failure: only Iridium sees it (would indicate a non-standard frame).

### COV-06 Revert restores the original cover — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Select `tagged.mp3`. 2. Change… → `cover.jpg`. 3. Revert.
Success: original PNG back; clean state; disk file untouched.
Failure: replacement kept; placeholder shown instead of original.

### COV-07 Non-image rejected — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Change… → `images/not-image.png`.
Success: toast `Only JPEG and PNG images are supported`; cover unchanged;
not dirty; journal has `cover-read-failed`.
Failure: accepted; crash; file marked dirty.

### COV-08 Oversized image rejected — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Change… → `images/big.png`.
Success: toast `Image is larger than 10 MB`; unchanged and clean.
Failure: app hangs loading it; accepted and written.

### COV-09 Corrupt image shows placeholder — Priority: P2 — Type: manual — Result: [ ]
Preconditions: a file whose embedded bytes do not decode. Simulate: run COV-03
with `images/corrupt.png` — the service accepts it (valid PNG magic, small),
so the bytes reach the widget.
Steps: 1. Change… → `images/corrupt.png`.
Success: placeholder shown, no crash; journal has `cover-decode-failed`.
Failure: crash in the texture loader; stale previous cover shown as if new.

### COV-10 Unselected files keep their pictures — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Open `tagged.mp3` (has cover) and `plain.mp3` (none), selecting only
`plain.mp3`. 2. Edit `plain.mp3` title, save. 3. Check `tagged.mp3` streams.
(auto test `/cover/unloaded-untouched` covers the mechanism.)
Success: `tagged.mp3` still has its cover.
Failure: cover stripped by saving an unrelated file.

### COV-11 Other formats — Priority: P2 — Type: manual — Result: [ ] — **(best-effort)**
Steps: 1. Repeat COV-01–COV-04 on `song.flac` and `song.m4a`.
Success: same behavior as MP3.
Failure (allowed): format rejects pictures — must fail as a toast +
`tag-save-failed`, file stays dirty, no crash. Log a defect regardless.

### COV-12 Multi-picture file collapses to one — Priority: P3 — Type: manual — Result: [ ]
Preconditions: an MP3 with front + back covers (attach two images with
`ffmpeg -map` twice, or reuse any such file).
Steps: 1. Select it (shows the first picture). 2. Change the cover. 3. Save.
4. Count video streams with `ffprobe`.
Success: exactly one picture stream; documented behavior, not data loss
beyond the extra pictures.
Failure: crash; zero pictures; duplicate streams accumulating per save.

## 10. Logging (LOG)

### LOG-01 Actions are logged — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Fresh run: launch, open `tagged.mp3`, select it, edit, save, revert
(a no-op revert is fine), quit.
Success: journal shows `app-start`, `open-files`, `scan`, `select`, `save`,
`app-quit`, each with `SYSLOG_IDENTIFIER=co.tylr.Iridium` and
`IRIDIUM_ACTION=<name>`.
Failure: any action missing; wrong identifier (entries invisible in Logs).

### LOG-02 Errors are warnings with codes — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open `fake.mp3`. 2. Save `readonly.mp3` after editing.
Success: `tag-read-failed` and `tag-save-failed` at WARNING priority with
`CODE` and `IRIDIUM_FILE` fields.
Failure: logged at INFO; missing CODE; shown as GTK-domain noise only.

### LOG-03 No full paths at INFO — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. `journalctl --user -t co.tylr.Iridium --since -10min -o verbose | grep -E "home|MESSAGE"`.
Success: messages contain basenames only.
Failure: home directory or full path in any INFO/WARNING message.

### LOG-04 Debug hidden by default — Priority: P3 — Type: manual — Result: [ ]
Covered by APP-03.
Success: no DEBUG lines normally; full paths appear with `--verbose`.
Failure: noisy journal in normal runs.

### LOG-05 Visible in GNOME Logs — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Open Logs, search `Iridium`.
Success: app entries listed with correct timestamps and levels.
Failure: absent (identifier mismatch) or misleveled.

## 10b. Translations (I18N)

Preconditions for all: app installed (`sudo meson install -C build`);
langpacks installed (see [02-getting-started](02-getting-started.md)).

### I18N-01 German UI smoke — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. `LANG=de_DE.UTF-8 iridium`. 2. Walk the empty state, open dialogs,
editor groups, save bar and About.
Success: "Keine Dateien geöffnet", "Speichern", "Zurücksetzen", "Über
Iridium"; no English leftovers in widgets; no crash.
Failure: English strings (catalog not loaded — check localedir install);
crash on missing locale (must fall back, never crash).

### I18N-02 French and Spanish spot check — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Repeat I18N-01 with `LANG=fr_FR.UTF-8` and `LANG=es_ES.UTF-8`.
Success: "Aucun fichier ouvert" / "Ningún archivo abierto"; About comments
translated.
Failure: untranslated strings (missing msgstr); wrong encoding (mojibake).

### I18N-03 Plural forms — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. In each language, open one bad file, then two bad files.
Success: singular/plural correct per language (fr: `n > 1`; es/de: `n != 1`).
Failure: "1 fichiers" style errors; `%u` placeholder dropped.

### I18N-04 Untranslated locale falls back — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. `LANG=ja_JP.UTF-8 iridium`.
Success: full English UI, no crash.
Failure: empty labels; crash.

### I18N-05 German layout holds — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. `LANG=de_DE.UTF-8 iridium`. 2. Narrow the window to ~600px.
Success: long compounds ("Ungespeicherte Änderungen") wrap or ellipsize;
no clipped buttons (extends UI-01 per locale).
Failure: overlapping widgets; save bar unreachable.

### I18N-06 POT is fresh — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. `meson compile -C build iridium-pot`. 2. `msgmerge` each `.po`
and `git diff --stat`.
Success: no new untranslated msgids after unrelated changes; new UI strings
from a feature branch appear here before merge.
Failure: strings missing from the POT (extraction gap — see risks in
[.features/translations](.features/translations.md)).

## 10c. Onboarding (ONB)

### ONB-01 Script check passes here — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. `tools/onboard.sh --check`. 2. With each opt-in flag.
Success: exit 0 and READY when everything is installed; lists exactly the
missing pieces otherwise, changing nothing.
Failure: false READY (missing tool not reported); any change made in
`--check` mode.

### ONB-02 Fresh-machine script review — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. Read `tools/onboard.sh` as a fresh Fedora install would run it.
2. Confirm every dnf name with `dnf list available <pkg>` and every Flatpak
ref against the manifest/Flathub.
Success: no typos, no stale versions, flags match `--help`.
Failure: script references anything not installable (full clean-room runs
need a fresh VM and are aspirational — see section 17).

## 11. UI and adaptive (UI)

### UI-01 Narrow window collapses — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. Shrink the window below ~600px.
Success: sidebar becomes a back-navigable page; editor usable; no clipped
buttons.
Failure: overlapping widgets; save bar unreachable.

### UI-02 Light and dark themes — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. Toggle the system style to dark and back.
Success: all text readable; placeholder and dirty dot visible in both.
Failure: invisible text; hardcoded colors.

### UI-03 Keyboard navigation — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. `Tab` through the window; use arrows in the file list.
Success: logical order: list → editor fields → Change/Remove → Save/Revert;
focus always visible; shortcuts from APP-04/SAV-03 work.
Failure: focus traps; invisible focus; list not arrow-navigable.

### UI-04 Accessible names — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. Inspect with Accerciser (or Orca) the list rows, cover buttons,
Save/Revert.
Success: every control has a name (title/artist labels, "Change…",
"Unsaved changes").
Failure: unnamed controls (`push-button` with no label).

## 12. Data integrity (DAT)

### DAT-01 Audio untouched by tag save — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Record `audio-hashes.txt` hash of `tagged.mp3`. 2. Edit all text
fields, save. 3. Recompute: `ffmpeg -v error -i tagged.mp3 -map 0:a -c copy
-f md5 -`.
Success: hash identical to the reference.
Failure: any difference means the audio was re-encoded or corrupted.

### DAT-02 Audio untouched by cover save — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Change and save the cover of `tagged.mp3`. 2. Compare the audio hash.
Success: identical.
Failure: hash changed.

### DAT-03 Permissions preserved — Priority: P2 — Type: manual — Result: [ ]
Steps: 1. `stat -c %a plain.mp3`, save a tag change. 2. Compare.
Success: mode bits unchanged.
Failure: file becomes world-writable or loses executability semantics
(TagLib rewrites in place; verify rather than assume).

### DAT-04 No truncation on failure — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. Note size of `readonly.mp3`. 2. Attempt save (fails, SAV-04).
3. Compare size and audio hash.
Success: byte-identical.
Failure: truncated or emptied file — stop the release, P0 defect.

## 13. Build and packaging (BLD)

### BLD-01 Clean build — Priority: P1 — Type: manual — Result: [ ]
Steps: 1. `rm -rf build && meson setup build && meson compile -C build`.
Success: no errors (C warnings from generated code are tolerated).
Failure: any `error:` line.

### BLD-02 Tests and validation — Priority: P1 — Type: auto+manual — Result: [ ]
Steps: 1. `meson test -C build`.
Success: all OK (7/7 with no optional tools; more when linters are installed).
Failure: any FAIL.

### BLD-04 vala-lint clean — Priority: P2 — Type: auto — Result: [ ]
Steps: 1. Install vala-lint (`tools/onboard.sh --with-lint`). 2. `meson test -C build lint-vala`.
Success: OK. Without the tool the test is absent (not a failure).
Failure: any error-level finding; fix the code, not the config.

### BLD-05 clang-tidy clean — Priority: P2 — Type: auto — Result: [ ]
Steps: 1. `sudo dnf install clang-tools-extra`. 2. `meson test -C build lint-c`.
Success: OK on `src/c/taglib-picture.c`. Absent without the tool.
Failure: any finding. (Never run on valac-generated C.)

### BLD-03 Flatpak build — Priority: P3 — Type: manual — Result: [ ]
Steps: 1. `flatpak-builder --force-clean build-flatpak co.tylr.Iridium.json`.
2. `flatpak run co.tylr.Iridium`, repeat APP-01 and SAV-01.
Success: builds against the pinned runtime; app runs; portal file access works.
Failure: blocked on sandbox issues — log, do not hold the native release.

## 14. Regression smoke list (before every release)

Run in order: BLD-01, BLD-02, APP-01, APP-02, OPN-02, TAG-01, TAG-02, SAV-01,
SAV-02, SAV-04, COV-01, COV-03, COV-04, COV-10, DAT-01, LOG-01.
All must pass; any failure blocks the release.

## 15. Run log

| Date | Commit | Tester | Build | Cases run | Pass | Fail | Skipped | Notes |
|---|---|---|---|---|---|---|---|---|
| 2026-10-03 | `3964447` | Tyler (dev) | native | APP-02 (partial) | 1 | 0 | rest | Launch + load only; no clicks |
| | | | | | | | | |

## 16. Defect template

```text
Case: COV-03
Build: native, commit <sha>
Fixture: /tmp/iridium-fixtures/plain.mp3 + images/cover.png
Expected: <from Success>
Actual: <what happened>
Journal: <relevant journalctl excerpt>
Regression? yes/no (did this pass before?)
```

## 17. Known gaps (suggested automated tests)

- Clean-room onboarding run (fresh Fedora VM + `tools/onboard.sh` + full
  build/test).

- Scanner: duplicate detection, nested folders, extension filter — needs a
  temp-dir test with real files.
- `AudioFile` dirty edge cases: cover-only change, revert order, double save.
- Logger: assert journal fields without a journal (capture `LogField`s via a
  test writer func).
- OPN-07 stress: time-boxed scan benchmark, not a unit test.
