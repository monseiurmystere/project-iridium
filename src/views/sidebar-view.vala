/** File list. Emits file_selected whenever the selection changes. */
[GtkTemplate (ui = "/co/tylr/Iridium/views/sidebar-view.ui")]
public class Iridium.SidebarView : Adw.Bin {
    [GtkChild] private unowned Gtk.ListView list_view;

    private Gtk.SingleSelection selection;

    public signal void file_selected (AudioFile? file);

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
