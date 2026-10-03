/**
 * Bottom bar revealed while the current file has unsaved changes. The window
 * binds AudioFile.dirty straight onto this property; the Save/Revert buttons
 * inside are win.* actions, so this class carries no logic.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/views/save-bar.ui")]
public class Iridium.SaveBar : Adw.Bin {
    [GtkChild] private unowned Gtk.Revealer revealer;

    /** Reveals (true) or hides the bar; bound to the current file's dirty. */
    public bool dirty {
        get { return revealer.reveal_child; }
        set { revealer.reveal_child = value; }
    }
}
