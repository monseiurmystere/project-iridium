namespace Iridium.FileScanner {
    /** Counts from a scan: files added to the store vs unreadable files. */
    public struct ScanResult {
        /** Files successfully read and appended to the store. */
        public uint added;
        /** Files skipped after a TagError (already logged, see AppLogger). */
        public uint failed;
    }

    /** Filename suffixes treated as audio. TagLib decides readability. */
    private const string[] EXTENSIONS = { "mp3", "flac", "ogg", "oga", "opus", "m4a" };
    /**
     * Cooperative yield interval. Tag reads are synchronous disk I/O, so the
     * loop hands the main loop a turn regularly; without this, opening a
     * large folder freezes the window until the scan finishes.
     */
    private const uint YIELD_EVERY = 25;

    /**
     * Adds the audio files in @inputs (files or folders, recursive) to @store.
     *
     * Files already in the store (compared by path) are skipped, so opening
     * the same file twice never duplicates a row. Unreadable files are
     * counted in the result and logged, never thrown: one bad file must not
     * abort the whole scan.
     */
    public async ScanResult scan (File[] inputs, ListStore store) {
        var known = new GenericSet<string> (str_hash, str_equal);
        for (uint i = 0; i < store.get_n_items (); i++) {
            known.add (((AudioFile) store.get_item (i)).path);
        }

        var result = ScanResult ();
        uint seen = 0;
        foreach (var path in collect (inputs)) {
            if (path in known) {
                continue;
            }
            try {
                store.append (new AudioFile (path, TagReader.read (path)));
                known.add (path);
                result.added++;
            } catch (TagError e) {
                AppLogger.error ("tag-read-failed", e.message, path);
                result.failed++;
            }
            if (++seen % YIELD_EVERY == 0) {
                Idle.add (scan.callback);
                yield;
            }
        }
        return result;
    }

    /**
     * Flattens @inputs to local audio paths. Folders are walked
     * breadth-first with an explicit queue (no recursion: deep trees must
     * not overflow the stack). Non-local files have no path and are skipped;
     * I/O errors are logged per file and do not stop the walk.
     */
    private string[] collect (File[] inputs) {
        string[] paths = {};
        var pending = new Queue<File> ();
        foreach (var f in inputs) {
            pending.push_tail (f);
        }
        while (!pending.is_empty ()) {
            var f = pending.pop_head ();
            try {
                var type = f.query_file_type (FileQueryInfoFlags.NONE);
                if (type == FileType.DIRECTORY) {
                    var en = f.enumerate_children ("standard::name", FileQueryInfoFlags.NONE);
                    FileInfo? info;
                    while ((info = en.next_file ()) != null) {
                        pending.push_tail (f.get_child (info.get_name ()));
                    }
                } else if (f.get_path () != null && is_audio (f.get_basename ())) {
                    paths += f.get_path ();
                }
            } catch (Error e) {
                AppLogger.error ("scan-failed", e.message, f.get_path ());
            }
        }
        return paths;
    }

    /** Case-insensitive extension check against EXTENSIONS. */
    private bool is_audio (string name) {
        var lower = name.down ();
        foreach (var ext in EXTENSIONS) {
            if (lower.has_suffix ("." + ext)) {
                return true;
            }
        }
        return false;
    }
}
