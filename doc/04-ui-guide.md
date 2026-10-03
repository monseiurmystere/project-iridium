# UI guide

## Patterns

1. **Composite templates.** Each view is a subclass annotated with
   `[GtkTemplate (ui = "/co/tylr/Iridium/views/<name>.ui")]`; the layout is in
   `<name>.blp`. Vala only holds `[GtkChild]` fields and logic.
2. **Model-view-factory lists.** `ListStore<AudioFile>` ->
   `SingleSelection` -> `ListView` + `SignalListItemFactory`. The factory only
   does setup/bind/unbind of `FileListRow`; no I/O in rows.
3. **One-way binding.** Rows use `bind_property` / `notify`. The editor uses
   explicit `load()` / `apply()` so dirty tracking works.
4. **Actions.** Commands are `GAction`s (`win.open-files`, `win.open-folder`,
   `win.save`, `win.revert`, `app.about`, `app.quit`). Blueprint binds buttons
   via `action-name`; accelerators are set in `application.vala`.
5. **Adaptive layout.** `Adw.NavigationSplitView`; a `Gtk.Stack` swaps the
   empty state for the main view.

We deliberately avoid callbacks in `.blp` (`=> $handler`). Connect signals in
Vala `construct {}` blocks instead.

## Adding a component

1. Create `src/views/foo.blp` with `template $IridiumFoo : Adw.Bin { ... }`.
2. Create `src/views/foo.vala` with `[GtkTemplate]`, `class Iridium.Foo`.
3. Add both to `src/meson.build` (`ui_sources`, `blueprints`) and the `.ui`
   to `src/iridium.gresource.xml`.
4. If a parent template uses it, call `typeof (Foo).ensure ()` in the
   parent's `static construct {}` so the type is registered first.
5. Keep it under the size rule in [03-architecture.md](03-architecture.md).

Blueprint type names are `Iridium` + class name (`$IridiumFoo`).
