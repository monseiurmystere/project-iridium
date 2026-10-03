namespace Iridium.TagReader {
    /** Reads the tag of the audio file at @path using TagLib. */
    public AudioTag read (string path) throws TagError {
        var file = new TagLib.File (path);
        if (!file.is_valid ()) {
            throw new TagError.OPEN (_("Cannot read tags from %s"),
                                     Path.get_basename (path));
        }
        unowned TagLib.Tag t = file.tag;
        var tag = new AudioTag ();
        tag.title = nz (t.title);
        tag.artist = nz (t.artist);
        tag.album = nz (t.album);
        tag.genre = nz (t.genre);
        tag.comment = nz (t.comment);
        tag.year = t.year;
        tag.track = t.track;
        TagLib.Tag.free_strings ();
        return tag;
    }

    /** Reads the embedded cover of @path, or null if there is none. */
    public CoverArt? read_cover (string path) throws TagError {
        var file = new TagLib.File (path);
        if (!file.is_valid ()) {
            throw new TagError.OPEN (_("Cannot read cover from %s"),
                                     Path.get_basename (path));
        }
        string? mime;
        var data = IridiumTagLib.get_picture (file, out mime);
        return data != null ? new CoverArt (data, mime ?? "application/octet-stream") : null;
    }

    private string nz (string? s) {
        return s ?? "";
    }
}
