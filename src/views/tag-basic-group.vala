/**
 * Title/artist/album/genre group. load() fills entries from a tag, apply()
 * writes them back; any keystroke emits edited. The details group mirrors
 * this shape for year/track/comment.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/views/tag-basic-group.ui")]
public class Iridium.TagBasicGroup : Adw.PreferencesGroup {
    [GtkChild] private unowned TagFieldRow title_row;
    [GtkChild] private unowned TagFieldRow artist_row;
    [GtkChild] private unowned TagFieldRow album_row;
    [GtkChild] private unowned TagFieldRow genre_row;

    /** Emitted on any keystroke; the editor applies it to the working tag. */
    public signal void edited ();

    static construct {
        typeof (TagFieldRow).ensure ();
    }

    construct {
        title_row.changed.connect (() => edited ());
        artist_row.changed.connect (() => edited ());
        album_row.changed.connect (() => edited ());
        genre_row.changed.connect (() => edited ());
    }

    /** Fills entries from @tag. Caller suppresses edited while doing so. */
    public void load (AudioTag tag) {
        title_row.text = tag.title;
        artist_row.text = tag.artist;
        album_row.text = tag.album;
        genre_row.text = tag.genre;
    }

    /** Writes entries back into @tag (marks it dirty via notify). */
    public void apply (AudioTag tag) {
        tag.title = title_row.text;
        tag.artist = artist_row.text;
        tag.album = album_row.text;
        tag.genre = genre_row.text;
    }
}
