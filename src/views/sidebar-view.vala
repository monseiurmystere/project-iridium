/**
 * File list. Wraps the window's store in a SingleSelection and emits
 * file_selected whenever the selection changes. Row widgets are created and
 * bound by the factory; this class never reads tags itself.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/views/sidebar-view.ui")]
public class Iridium.SidebarView : Adw.Bin {
    [GtkChild] private unowned Gtk.ListView list_view;

    private Gtk.SingleSelection selection;

    /** Emitted on every selection change; null when nothing is selected. */
    public signal void file_selected (AudioFile? file);

    /** The window's ListStore; wrapped in selection state on assignment. */
    public ListModel model {
        set {
            selection = new Gtk.SingleSelection (value);
            selection.notify["selected-item"].connect (() => {
                file_selected (selection.selected_item as AudioFile);
            });
            list_view.model = selection;
        }
    }

    static construct {
        typeof (FileListRow).ensure ();
    }

    construct {
        // One recycled row widget per visible row: setup creates, bind points
        // it at an AudioFile, unbind releases it (see FileListRow.file).
        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect ((obj) => {
            ((Gtk.ListItem) obj).child = new FileListRow ();
        });
        factory.bind.connect ((obj) => {
            var item = (Gtk.ListItem) obj;
            ((FileListRow) item.child).file = item.item as AudioFile;
        });
        factory.unbind.connect ((obj) => {
            ((FileListRow) ((Gtk.ListItem) obj).child).file = null;
        });
        list_view.factory = factory;
    }
}
