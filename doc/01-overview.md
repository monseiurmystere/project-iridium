# Overview

Iridium (`co.tylr.Iridium`) is a native GNOME audio tag editor (ID3 for MP3,
plus Vorbis/FLAC/MP4 tags through TagLib).

| Concern        | Choice                                   |
|----------------|------------------------------------------|
| Language       | Vala                                     |
| Toolkit        | GTK4 + libadwaita                        |
| UI definition  | Blueprint (`.blp`) composite templates   |
| Tag I/O        | TagLib C API (`taglib_c`, vapi ships with Vala) |
| Build          | Meson                                    |
| Packaging      | Flatpak (`co.tylr.Iridium.json`)         |
| Logging        | systemd journal, stderr fallback         |

## Scope (v0.1)

Open files/folders (dialog, drag and drop, CLI args), list them, edit
title/artist/album/genre/year/track/comment, save/revert with dirty tracking.

Planned features are tracked in [.features](.features/README.md).
