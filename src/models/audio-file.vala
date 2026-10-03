/**
 * One file on disk: working tag, last-saved snapshot and dirty state.
 * The cover is loaded lazily (on selection); until then it is never written.
 */
public class Iridium.AudioFile : Object {
    public string path { get; construct; }
    public AudioTag tag { get; private set; }
    public AudioTag saved { get; private set; }
    public CoverArt? cover { get; private set; default = null; }
    public bool cover_loaded { get; private set; default = false; }
    public bool dirty { get; private set; default = false; }

    private CoverArt? saved_cover = null;

    public string basename {
        owned get { return Path.get_basename (path); }
    }

    public string display_title {
        owned get { return tag.title != "" ? tag.title : basename; }
    }

    public string display_artist {
        get { return tag.artist; }
    }

    /** True once a loaded cover differs from the one on disk. */
    public bool cover_changed {
        get { return cover_loaded && !CoverArt.same (cover, saved_cover); }
    }

    public AudioFile (string path, AudioTag loaded) {
        Object (path: path);
        saved = loaded;
        tag = loaded.duplicate ();
        tag.notify.connect (update_dirty);
    }

    /** Records the cover found on disk. */
    public void load_cover (CoverArt? on_disk) {
        saved_cover = on_disk;
        cover = on_disk;
        cover_loaded = true;
        update_dirty ();
    }

    public void replace_cover (CoverArt? value) {
        cover = value;
        update_dirty ();
    }

    public void mark_saved () {
        saved.copy_from (tag);
        saved_cover = cover;
        update_dirty ();
    }

    public void revert () {
        tag.copy_from (saved);
        cover = saved_cover;
        update_dirty ();
    }

    private void update_dirty () {
        dirty = !tag.equals (saved) || cover_changed;
        notify_property ("display-title");
        notify_property ("display-artist");
    }
}
