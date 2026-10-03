# Batch edit

**Status:** Idea, not planned.

## Goal
Edit tags of several selected files at once. Fields whose values differ show
a "mixed values" placeholder and are left untouched unless edited.

## Open questions
- Multi-selection in the sidebar (`Gtk.MultiSelection`) and how the editor
  reflects it.
- Interaction with per-file dirty tracking and Save/Revert.
- Which fields make sense in batch (not title or track).
