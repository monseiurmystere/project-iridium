/**
 * Hosts the cover and tag groups. Edits are written live into the file's
 * working tag (via apply on every edited signal); the window observes
 * AudioFile.dirty for save/revert state. No I/O happens here.
 */
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

    /**
     * Fills the groups from @file (null clears and desensitizes). The
     * loading flag suppresses edited signals while entries are set
     * programmatically, so loading never marks a file dirty.
     */
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

    /** Refreshes the cover preview without touching the tag groups. */
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
