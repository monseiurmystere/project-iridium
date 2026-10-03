/**
 * Shows the cover (or a placeholder). Display-only: the Change/Remove
 * buttons trigger win.* actions handled by the window. An undecodable cover
 * falls back to the placeholder and logs, rather than failing selection.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/widgets/cover-art-widget.ui")]
public class Iridium.CoverArtWidget : Adw.Bin {
    [GtkChild] private unowned Gtk.Stack stack;
    [GtkChild] private unowned Gtk.Picture picture;

    /** Shows @cover, or the placeholder when null or undecodable. */
    public void show_cover (CoverArt? cover) {
        if (cover != null) {
            try {
                picture.paintable = Gdk.Texture.from_bytes (cover.data);
                stack.visible_child_name = "picture";
                return;
            } catch (Error e) {
                AppLogger.error ("cover-decode-failed", e.message);
            }
        }
        picture.paintable = null;
        stack.visible_child_name = "empty";
    }
}
