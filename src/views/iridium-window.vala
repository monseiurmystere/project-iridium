/** Window shell: owns the file store, actions and selection wiring. */
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
    };

    static construct {
        typeof (EmptyStateView).ensure ();
        typeof (SidebarView).ensure ();
        typeof (TagEditorView).ensure ();
        typeof (SaveBar).ensure ();
    }

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

    public void add_files (File[] files) {
        scan.begin (files);
    }

    private async void scan (File[] files) {
        var result = yield FileScanner.scan (files, store);
        AppLogger.action ("scan", "added=%u failed=%u".printf (result.added, result.failed));
        if (store.get_n_items () > 0) {
            root_stack.visible_child_name = "main";
        }
        if (result.failed > 0) {
            toast ("Could not read %u file(s)".printf (result.failed));
        }
    }

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

    private void on_file_selected (AudioFile? file) {
        if (current != null && dirty_handler != 0) {
            current.disconnect (dirty_handler);
            dirty_handler = 0;
        }
        dirty_binding?.unbind ();
        dirty_binding = null;

        current = file;
        editor.load (file);
        save_bar.dirty = false;
        if (file != null) {
            dirty_binding = file.bind_property ("dirty", save_bar, "dirty",
                                                BindingFlags.SYNC_CREATE);
            dirty_handler = file.notify["dirty"].connect (update_actions);
            AppLogger.action ("select", file.basename);
        }
        update_actions ();
    }

    private void update_actions () {
        var dirty = current != null && current.dirty;
        ((SimpleAction) lookup_action ("save")).set_enabled (dirty);
        ((SimpleAction) lookup_action ("revert")).set_enabled (dirty);
    }

    private void on_open_files () {
        pick_input.begin (false);
    }

    private void on_open_folder () {
        pick_input.begin (true);
    }

    private async void pick_input (bool folder) {
        var files = folder ? yield Dialogs.pick_folder (this)
                           : yield Dialogs.pick_files (this);
        if (files.length > 0) {
            AppLogger.action (folder ? "open-folder" : "open-files",
                              "count=%d".printf (files.length));
            add_files (files);
        }
    }

    private void on_save () {
        if (current == null) {
            return;
        }
        try {
            TagWriter.write (current);
            AppLogger.action ("save", current.basename);
            toast ("Saved %s".printf (current.basename));
        } catch (TagError e) {
            AppLogger.error ("tag-save-failed", e.message, current.path);
            toast (e.message);
        }
    }

    private void on_revert () {
        if (current == null) {
            return;
        }
        current.revert ();
        editor.load (current);
        AppLogger.action ("revert", current.basename);
    }

    private void toast (string message) {
        toasts.add_toast (new Adw.Toast (message));
    }
}
