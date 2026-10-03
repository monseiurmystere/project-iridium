[GtkTemplate (ui = "/co/tylr/Iridium/views/tag-details-group.ui")]
public class Iridium.TagDetailsGroup : Adw.PreferencesGroup {
    [GtkChild] private unowned TagFieldRow year_row;
    [GtkChild] private unowned TagFieldRow track_row;
    [GtkChild] private unowned TagFieldRow comment_row;

    public signal void edited ();

    static construct {
        typeof (TagFieldRow).ensure ();
    }

    construct {
        year_row.changed.connect (() => edited ());
        track_row.changed.connect (() => edited ());
        comment_row.changed.connect (() => edited ());
    }

    public void load (AudioTag tag) {
        year_row.set_uint (tag.year);
        track_row.set_uint (tag.track);
        comment_row.text = tag.comment;
    }

    public void apply (AudioTag tag) {
        tag.year = year_row.get_uint ();
        tag.track = track_row.get_uint ();
        tag.comment = comment_row.text;
    }
}
