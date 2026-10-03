/**
 * Year/track/comment group. Mirrors TagBasicGroup's load/apply/edited
 * contract; year and track go through the numeric TagFieldRow helpers.
 */
[GtkTemplate (ui = "/co/tylr/Iridium/views/tag-details-group.ui")]
public class Iridium.TagDetailsGroup : Adw.PreferencesGroup {
    [GtkChild] private unowned TagFieldRow year_row;
    [GtkChild] private unowned TagFieldRow track_row;
    [GtkChild] private unowned TagFieldRow comment_row;

    /** Emitted on any keystroke; the editor applies it to the working tag. */
    public signal void edited ();

    static construct {
        typeof (TagFieldRow).ensure ();
    }

    construct {
        year_row.changed.connect (() => edited ());
        track_row.changed.connect (() => edited ());
        comment_row.changed.connect (() => edited ());
    }

    /** Fills entries from @tag. Caller suppresses edited while doing so. */
    public void load (AudioTag tag) {
        year_row.set_uint (tag.year);
        track_row.set_uint (tag.track);
        comment_row.text = tag.comment;
    }

    /** Writes entries back into @tag (marks it dirty via notify). */
    public void apply (AudioTag tag) {
        tag.year = year_row.get_uint ();
        tag.track = track_row.get_uint ();
        tag.comment = comment_row.text;
    }
}
