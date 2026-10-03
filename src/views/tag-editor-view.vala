/** Hosts the tag groups. Edits are written live into the file's working tag. */
[GtkTemplate (ui = "/co/tylr/Iridium/views/tag-editor-view.ui")]
public class Iridium.TagEditorView : Adw.Bin {
    [GtkChild] private unowned CoverArtWidget cover_art;
    [GtkChild] private unowned TagBasicGroup basic;
    [GtkChild] private unowned TagDetailsGroup details;

    private AudioFile? current = null;
    private bool loading = false;

    static construct {
        typeof (CoverArtWidget).ensure ();
        typeof (TagBasicGroup).ensure ();
        typeof (TagDetailsGroup).ensure ();
    }

    construct {
        basic.edited.connect (on_edited);
        details.edited.connect (on_edited);
    }

    public void load (AudioFile? file) {
        loading = true;
        current = file;
        sensitive = file != null;
        if (file != null) {
            basic.load (file.tag);
            details.load (file.tag);
        }
        cover_art.show_cover (file != null ? file.cover : null);
        loading = false;
    }

    public void show_cover (CoverArt? cover) {
        cover_art.show_cover (cover);
    }

    private void on_edited () {
        if (loading || current == null) {
            return;
        }
        basic.apply (current.tag);
        details.apply (current.tag);
    }
}
