/** One file on disk: its working tag, last-saved snapshot and dirty state. */
public class Iridium.AudioFile : Object {
    public string path { get; construct; }
    public AudioTag tag { get; private set; }
    public AudioTag saved { get; private set; }
    public bool dirty { get; private set; default = false; }

    public string basename {
        owned get { return Path.get_basename (path); }
    }

    public string display_title {
        owned get { return tag.title != "" ? tag.title : basename; }
    }

    public string display_artist {
        get { return tag.artist; }
    }

    public AudioFile (string path, AudioTag loaded) {
        Object (path: path);
        saved = loaded;
        tag = loaded.duplicate ();
        tag.notify.connect (on_tag_changed);
    }

    public void mark_saved () {
        saved.copy_from (tag);
        on_tag_changed ();
    }

    public void revert () {
        tag.copy_from (saved);
    }

    private void on_tag_changed () {
        dirty = !tag.equals (saved);
        notify_property ("display-title");
        notify_property ("display-artist");
    }
}
