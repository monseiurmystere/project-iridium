/**
 * Window shell: owns the file store, all win.* actions and the selection
 * wiring between sidebar, editor and save bar. Views stay passive — every
 * service call (scan, read, write) is initiated here.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/views/iridium-window.ui")]
public class Iridium.Window : Adw.ApplicationWindow {
    [GtkChild] private unowned Adw.ToastOverlay toasts;
    [GtkChild] private unowned Gtk.Stack root_stack;
    [GtkChild] private unowned SidebarView sidebar;
    [GtkChild] private unowned TagEditorView editor;
    [GtkChild] private unowned SaveBar save_bar;

    private ListStore store = new ListStore (typeof (AudioFile));
    private AudioFile? current = null;
    private Binding? dirty_binding = null;
    private ulong dirty_handler = 0;

    private const ActionEntry[] ACTIONS = {
        { "open-files", on_open_files },
        { "open-folder", on_open_folder },
        { "save", on_save },
        { "revert", on_revert },
        { "change-cover", on_change_cover },
        { "remove-cover", on_remove_cover },
    };

    // Custom widget types must be registered before this template is parsed,
    // otherwise the .ui lookup fails. Each composite widget needs one line.
    static construct {
        typeof (EmptyStateView).ensure ();
        typeof (SidebarView).ensure ();
        typeof (TagEditorView).ensure ();
        typeof (SaveBar).ensure ();
    }

    /** Creates the window for @app; widgets come from the .ui template. */
    public Window (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        add_action_entries (ACTIONS, this);
        sidebar.model = store;
        sidebar.file_selected.connect (on_file_selected);
        editor.load (null);
        update_actions ();

        var drop = new Gtk.DropTarget (typeof (Gdk.FileList), Gdk.DragAction.COPY);
        drop.drop.connect (on_drop);
        ((Gtk.Widget) this).add_controller (drop);
    }

    /**
     * Entry point for every open path (dialog, drop, CLI). Fire-and-forget:
     * completion surfaces as new rows; failures as toasts (see scan).
     */
    public void add_files (File[] files) {
        scan.begin (files);
    }

    /**
     * Runs the scan, then swaps the empty state for the main view once at
     * least one file exists. A partial failure still shows the files that
     * did load, plus a counted toast — never a bare error.
     */
    private async void scan (File[] files) {
        var result = yield FileScanner.scan (files, store);
        AppLogger.action ("scan", "added=%u failed=%u".printf (result.added, result.failed));
        if (store.get_n_items () > 0) {
            root_stack.visible_child_name = "main";
        }
        if (result.failed > 0) {
            toast (ngettext ("Could not read %u file", "Could not read %u files",
                               result.failed).printf (result.failed));
        }
    }

    /** Accepts file drops anywhere on the window (same path as dialogs). */
    private bool on_drop (Value value, double x, double y) {
        var list = (Gdk.FileList) value.get_boxed ();
        File[] files = {};
        foreach (var f in list.get_files ()) {
            files += f;
        }
        AppLogger.action ("drop-files", "count=%d".printf (files.length));
        add_files (files);
        return true;
    }

    /**
     * Switches selection. The previous file's notify handler is disconnected
     * and its binding unbound first — without this, edits to a deselected
     * file would keep driving this window's save bar and actions.
     */
    private void on_file_selected (AudioFile? file) {
        if (current != null && dirty_handler != 0) {
            current.disconnect (dirty_handler);
            dirty_handler = 0;
        }
        dirty_binding?.unbind ();
        dirty_binding = null;

        current = file;
        ensure_cover (file);
        editor.load (file);
        save_bar.dirty = false;
        if (file != null) {
            dirty_binding = file.bind_property ("dirty", save_bar, "dirty",
                                                BindingFlags.SYNC_CREATE);
            dirty_handler = file.notify.connect (() => update_actions ());
            AppLogger.action ("select", file.basename);
        }
        update_actions ();
    }

    /** Enables actions from selection state; called on every dirty change. */
    private void update_actions () {
        var dirty = current != null && current.dirty;
        ((SimpleAction) lookup_action ("save")).set_enabled (dirty);
        ((SimpleAction) lookup_action ("revert")).set_enabled (dirty);
        ((SimpleAction) lookup_action ("change-cover")).set_enabled (current != null);
        ((SimpleAction) lookup_action ("remove-cover")).set_enabled (
            current != null && current.cover != null);
    }

    /**
     * Lazy cover load: once per file, on first selection. A failed read is
     * logged and cached as "no cover" so selection never throws and the
     * retry happens only on the next run, not on every click.
     */
    private void ensure_cover (AudioFile? file) {
        if (file == null || file.cover_loaded) {
            return;
        }
        try {
            file.load_cover (TagReader.read_cover (file.path));
        } catch (TagError e) {
            AppLogger.error ("cover-read-failed", e.message, file.path);
            file.load_cover (null);
        }
    }

    private void on_change_cover () {
        change_cover.begin ();
    }

    /** Validates and stages the picked image; saving happens via win.save. */
    private async void change_cover () {
        var image = yield Dialogs.pick_image (this);
        if (image == null || current == null) {
            return;
        }
        try {
            current.replace_cover (CoverArtService.load (image));
            editor.show_cover (current.cover);
            AppLogger.action ("cover-change", current.basename);
        } catch (TagError e) {
            AppLogger.error ("cover-read-failed", e.message, image.get_path ());
            toast (e.message);
        }
    }

    /** Stages cover removal; saving happens via win.save. */
    private void on_remove_cover () {
        if (current == null) {
            return;
        }
        current.replace_cover (null);
        editor.show_cover (null);
        AppLogger.action ("cover-remove", current.basename);
    }

    private void on_open_files () {
        pick_input.begin (false);
    }

    private void on_open_folder () {
        pick_input.begin (true);
    }

    // Named pick_input (not pick): Gtk.Widget.pick is an inherited method and
    // Vala warns when a subclass member hides it without the `new' keyword.
    private async void pick_input (bool folder) {
        var files = folder ? yield Dialogs.pick_folder (this)
                           : yield Dialogs.pick_files (this);
        if (files.length > 0) {
            AppLogger.action (folder ? "open-folder" : "open-files",
                              "count=%d".printf (files.length));
            add_files (files);
        }
    }

    /**
     * Writes the current file. On failure the working tag is untouched and
     * the file stays dirty, so the user can fix the cause and retry.
     */
    private void on_save () {
        if (current == null) {
            return;
        }
        try {
            TagWriter.write (current);
            AppLogger.action ("save", current.basename);
            toast (_("Saved %s").printf (current.basename));
        } catch (TagError e) {
            AppLogger.error ("tag-save-failed", e.message, current.path);
            toast (e.message);
        }
    }

    /** Restores on-disk state into the working tag and refreshes the editor. */
    private void on_revert () {
        if (current == null) {
            return;
        }
        current.revert ();
        editor.load (current);
        AppLogger.action ("revert", current.basename);
    }

    /** Shows a transient message; every user-facing failure ends here. */
    private void toast (string message) {
        toasts.add_toast (new Adw.Toast (message));
    }
}
