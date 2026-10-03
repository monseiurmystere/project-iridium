namespace Iridium.TagWriter {
    /** Writes the working tag of @audio to disk, then marks it saved. */
    public void write (AudioFile audio) throws TagError {
        var file = new TagLib.File (audio.path);
        if (!file.is_valid ()) {
            throw new TagError.OPEN ("Cannot open %s", audio.basename);
        }
        unowned TagLib.Tag t = file.tag;
        var tag = audio.tag;
        t.title = tag.title;
        t.artist = tag.artist;
        t.album = tag.album;
        t.genre = tag.genre;
        t.comment = tag.comment;
        t.year = tag.year;
        t.track = tag.track;
        if (!file.save ()) {
            throw new TagError.SAVE ("Cannot save %s (is it read-only?)",
                                     audio.basename);
        }
        audio.mark_saved ();
    }
}
