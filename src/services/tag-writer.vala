namespace Iridium.TagWriter {
    /** Writes the working tag of @audio to disk, then marks it saved. */
    public void write (AudioFile audio) throws TagError {
        var file = new TagLib.File (audio.path);
        if (!file.is_valid ()) {
            throw new TagError.OPEN (_("Cannot open %s"), audio.basename);
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
        if (audio.cover_changed && !write_cover (file, audio.cover)) {
            throw new TagError.SAVE (_("%s does not support cover art"), audio.basename);
        }
        if (!file.save ()) {
            throw new TagError.SAVE (_("Cannot save %s (is it read-only?)"),
                                     audio.basename);
        }
        audio.mark_saved ();
    }

    private bool write_cover (TagLib.File file, CoverArt? cover) {
        return cover != null
            ? IridiumTagLib.set_picture (file, cover.data, cover.mime_type)
            : IridiumTagLib.clear_picture (file);
    }
}
