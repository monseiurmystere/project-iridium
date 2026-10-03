/** Bottom bar revealed while the current file has unsaved changes. */
[GtkTemplate (ui = "/co/tylr/Iridium/views/save-bar.ui")]
public class Iridium.SaveBar : Adw.Bin {
    [GtkChild] private unowned Gtk.Revealer revealer;

    public bool dirty {
        get { return revealer.reveal_child; }
        set { revealer.reveal_child = value; }
    }
}
