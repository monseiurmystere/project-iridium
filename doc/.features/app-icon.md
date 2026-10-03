# App icon

**Status:** Placeholder in use (`data/icons/co.tylr.Iridium.svg`: blue rounded
square with a ring). A real icon will be chosen later.

## Design language requirement
Iridium uses GTK4 and libadwaita, so every icon or raster image must align
with the GNOME design language:

- Follow the GNOME Human Interface Guidelines for app icons
  (https://developer.gnome.org/hig/guidelines/app-icons.html).
- App icon: scalable SVG, 128x128 grid, distinct silhouette, modern GNOME
  style (soft gradients and shadows, not flat clip art).
- Provide a symbolic variant, `co.tylr.Iridium-symbolic.svg` (16x16,
  monochrome, recolorable).
- Stay within the GNOME palette. Prefer SVG over raster images.
- Illustrations (e.g. empty-state graphics) follow the same style; prefer the
  stock symbolic icons where possible.
- Name files after the app ID and keep metainfo and the Flatpak export in sync.

## Checklist before replacing
- [ ] Review with the GNOME App Icon Preview and Icon Library tools
- [ ] Check on light and dark backgrounds
- [ ] Add the symbolic variant and install it in `data/meson.build`
