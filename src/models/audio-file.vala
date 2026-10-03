/**
 * One file on disk: working tag, last-saved snapshot and dirty state.
 * The cover is loaded lazily (on selection); until then it is never written.
 */
public class Iridium.AudioFile : Object {
    /** Absolute filesystem path. Set once, never changes. */
    public string path { get; construct; }
    /** Working tag: the editor writes here on every keystroke. */
    public AudioTag tag { get; private set; }
    /** Last-saved snapshot of the text fields; dirty = tag differs from this. */
    public AudioTag saved { get; private set; }
    /** Working cover, or null for "no cover". Only meaningful when cover_loaded. */
    public CoverArt? cover { get; private set; default = null; }
    /**
     * Whether the on-disk cover has been read (once, on selection).
     * While false the writer leaves embedded pictures alone, so saving an
     * unselected file can never strip a cover it never saw.
     */
    public bool cover_loaded { get; private set; default = false; }
    /** True when text fields or the loaded cover differ from disk. */
    public bool dirty { get; private set; default = false; }

    private CoverArt? saved_cover = null;

    /** Filename without directories, for rows, toasts and logs. */
    public string basename {
        owned get { return Path.get_basename (path); }
    }

    /** Row title: the tag title, falling back to the filename when empty. */
    public string display_title {
        owned get { return tag.title != "" ? tag.title : basename; }
    }

    /** Row subtitle, bound live so edits appear while typing. */
    public string display_artist {
        get { return tag.artist; }
    }

    /** True once a loaded cover differs from the one on disk. */
    public bool cover_changed {
        get { return cover_loaded && !CoverArt.same (cover, saved_cover); }
    }

    /**
     * Builds the model around @loaded: it becomes the saved snapshot while
     * a duplicate becomes the working tag, so construction never marks dirty.
     */
    public AudioFile (string path, AudioTag loaded) {
        Object (path: path);
        saved = loaded;
        tag = loaded.duplicate ();
        tag.notify.connect (update_dirty);
    }

    /**
     * Caches the on-disk state: the cover snapshot and the working copy
     * start identical, so a freshly selected file is always clean.
     */
    public void load_cover (CoverArt? on_disk) {
        saved_cover = on_disk;
        cover = on_disk;
        cover_loaded = true;
        update_dirty ();
    }

    /** Replaces the working cover (null removes it) and recomputes dirty. */
    public void replace_cover (CoverArt? value) {
        cover = value;
        update_dirty ();
    }

    /** Snapshots working state as saved. Call only after a successful write. */
    public void mark_saved () {
        saved.copy_from (tag);
        saved_cover = cover;
        update_dirty ();
    }

    /** Restores working tag and cover from the snapshots. Never touches disk. */
    public void revert () {
        tag.copy_from (saved);
        cover = saved_cover;
        update_dirty ();
    }

    /**
     * Recomputes dirty and re-emits the display properties, so bound list
     * rows update on every keystroke. Wired to tag.notify in the constructor;
     * cover changes call it explicitly.
     */
    private void update_dirty () {
        dirty = !tag.equals (saved) || cover_changed;
        notify_property ("display-title");
        notify_property ("display-artist");
    }
}
