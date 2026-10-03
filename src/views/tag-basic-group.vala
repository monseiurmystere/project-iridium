[GtkTemplate (ui = "/co/tylr/Iridium/views/tag-basic-group.ui")]
public class Iridium.TagBasicGroup : Adw.PreferencesGroup {
    [GtkChild] private unowned TagFieldRow title_row;
    [GtkChild] private unowned TagFieldRow artist_row;
    [GtkChild] private unowned TagFieldRow album_row;
    [GtkChild] private unowned TagFieldRow genre_row;

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

    public void load (AudioTag tag) {
        title_row.text = tag.title;
        artist_row.text = tag.artist;
        album_row.text = tag.album;
        genre_row.text = tag.genre;
    }

    public void apply (AudioTag tag) {
        tag.title = title_row.text;
        tag.artist = artist_row.text;
        tag.album = album_row.text;
        tag.genre = genre_row.text;
    }
}
