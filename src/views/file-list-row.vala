/**
 * One recycled sidebar row. Binds its labels to an AudioFile's display
 * properties and the dirty dot to its dirty flag; unbinds everything when
 * released (null) so a recycled widget never shows stale data.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/views/file-list-row.ui")]
public class Iridium.FileListRow : Gtk.Box {
    [GtkChild] private unowned Gtk.Label title_label;
    [GtkChild] private unowned Gtk.Label subtitle_label;
    [GtkChild] private unowned Gtk.Image dirty_dot;

    private Binding[] bindings = {};
    private AudioFile? _file = null;

    /**
     * The file shown, or null to release. Rebinding unbinds the previous
     * file first; SYNC_CREATE paints immediately without waiting for notify.
     */
    public AudioFile? file {
        get { return _file; }
        set {
            foreach (var b in bindings) {
                b.unbind ();
            }
            bindings = {};
            _file = value;
            if (value == null) {
                return;
            }
            var flags = BindingFlags.SYNC_CREATE;
            bindings += value.bind_property ("display-title", title_label, "label", flags);
            bindings += value.bind_property ("display-artist", subtitle_label, "label", flags);
            bindings += value.bind_property ("dirty", dirty_dot, "visible", flags);
        }
    }
}
