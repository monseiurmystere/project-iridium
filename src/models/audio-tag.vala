/** Editable tag fields common to all supported formats. */
public class Iridium.AudioTag : Object {
    public string title { get; set; default = ""; }
    public string artist { get; set; default = ""; }
    public string album { get; set; default = ""; }
    public string genre { get; set; default = ""; }
    public string comment { get; set; default = ""; }
    public uint year { get; set; default = 0; }
    public uint track { get; set; default = 0; }

    public void copy_from (AudioTag other) {
        title = other.title;
        artist = other.artist;
        album = other.album;
        genre = other.genre;
        comment = other.comment;
        year = other.year;
        track = other.track;
    }

    public AudioTag duplicate () {
        var copy = new AudioTag ();
        copy.copy_from (this);
        return copy;
    }

    public bool equals (AudioTag other) {
        return title == other.title && artist == other.artist
            && album == other.album && genre == other.genre
            && comment == other.comment && year == other.year
            && track == other.track;
    }
}
