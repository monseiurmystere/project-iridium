/** Shows the cover (or a placeholder). Change/Remove are window actions. */
[GtkTemplate (ui = "/co/tylr/Iridium/widgets/cover-art-widget.ui")]
public class Iridium.CoverArtWidget : Adw.Bin {
    [GtkChild] private unowned Gtk.Stack stack;
    [GtkChild] private unowned Gtk.Picture picture;

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
