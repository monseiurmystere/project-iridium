# UI translation (French, Spanish, German)

**Status:** In progress (wired + LLM drafts committed; REVIEW REQUIRED before release).

## Goal
Full user interface in French (`fr`), Spanish (`es`) and German (`de`),
alongside English. Translation drafts are LLM-produced and must be reviewed
by Tyler before merge.

## Decisions
- Scope is all user-visible strings: Blueprint labels, toasts, dialog titles
  and filters, `TagError` messages shown as toasts, `about.json` values, the
  desktop entry and metainfo.
- `about.json`: `_()` is applied to values after the JSON is loaded, with
  extraction hints so xgettext picks the strings up.
- Log messages and journal entries stay English. They are diagnostics, and
  translating them would break `journalctl` greppability.

## Design
1. `po/` directory with `POTFILES`, `LINGUAS` (`fr es de`) and one `.po` per
   language; wired via `subdir('po')` and `i18n.gettext()`.
2. Runtime locale init in `application.vala` startup
   (`Intl.setlocale()` + `bindtextdomain()`), with `GETTEXT_PACKAGE` and
   `LOCALEDIR` supplied through `config.vala`.
3. String audit of all `.vala` sources: user-visible literals wrapped in
   `_()`; `"Could not read %u file(s)"` converted to `ngettext` for correct
   plurals.
4. `.desktop` and `.metainfo.xml` via `i18n.merge_file`.
5. Extraction runs over `.vala` sources plus the generated `.ui` files (the
   build already produces them), because xgettext does not understand `.blp`.
   Verify the POT is complete before writing translations.
6. Local testing needs `glibc-langpack-fr`, `glibc-langpack-es` and
   `glibc-langpack-de` on Fedora (`LANG=fr_FR.UTF-8 ./build/src/iridium`).
   Flatpak locales come from the `org.gnome.Platform.Locale` extension;
   no manifest change expected, but verify once.

## Implementation notes (deviations from the design above)
- `GETTEXT_PACKAGE` also had to be defined for the C compiler
  (`add_project_arguments('-DGETTEXT_PACKAGE="iridium"', language: 'c')`),
  because Vala's `_()` expands to `g_dgettext`.
- `.mo` files are compiled at install time via `po/install-mo.py`: sibling
  Meson targets cannot produce same-named outputs.
- xgettext language flags leak across file groups in one invocation, so
  `po/extract-pot.py` runs one xgettext per group and merges with msgcat.
- `msgmerge -U` resets the `.po` header, so `po/fill-drafts.py` re-enforces
  `Plural-Forms` afterwards.

## Steps
1. This file + index update (done).
2. gettext wiring + `po/` scaffold.
3. String audit (`_()` / `ngettext`).
4. `about.json` runtime lookup.
5. Desktop/metainfo merge.
6. LLM-draft fr/es/de `.po` content + Tyler review.
7. Docs + new `I18N-*` cases in the test plan.
8. Flatpak locale check.

## Risks
- **`.blp` extraction is the main risk.** If generated-`.ui` extraction misses
  strings, the fallback is a checked-in string list for xgettext. Do not write
  translations until the POT is verified complete.
- **German string length.** Compounds overflow fixed-width spots (sidebar
  rows, save bar). Re-check UI-01/UI-02 style cases per locale.
- **Draft quality.** LLM drafts are a starting point; wrong gender/plurals are
  expected. Nothing merges without review.
- **Translator-facing churn.** Every new UI string afterwards needs `.po`
  updates; `08-contributing.md` must say so.
