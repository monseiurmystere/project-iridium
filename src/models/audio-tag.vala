/**
 * Editable tag fields common to all supported formats. Plain data: no I/O,
 * no dirty tracking here (see AudioFile). Empty string means "not set";
 * year/track use 0 for the same.
 */
public class Iridium.AudioTag : Object {
    /** Track title; "" when unset. */
    public string title { get; set; default = ""; }
    /** Track artist; "" when unset. */
    public string artist { get; set; default = ""; }
    /** Album name; "" when unset. */
    public string album { get; set; default = ""; }
    /** Genre label; "" when unset. */
    public string genre { get; set; default = ""; }
    /** Free comment; "" when unset. */
    public string comment { get; set; default = ""; }
    /** Release year; 0 when unset. */
    public uint year { get; set; default = 0; }
    /** Track number; 0 when unset. */
    public uint track { get; set; default = 0; }

    /** Copies every field from @other. Emits one notify per changed property. */
    public void copy_from (AudioTag other) {
        title = other.title;
        artist = other.artist;
        album = other.album;
        genre = other.genre;
        comment = other.comment;
        year = other.year;
        track = other.track;
    }

    /** Deep copy; the original and the copy share nothing mutable. */
    public AudioTag duplicate () {
        var copy = new AudioTag ();
        copy.copy_from (this);
        return copy;
    }

    /** Field-by-field comparison; drives AudioFile.dirty. */
    public bool equals (AudioTag other) {
        return title == other.title && artist == other.artist
            && album == other.album && genre == other.genre
            && comment == other.comment && year == other.year
            && track == other.track;
    }
}
