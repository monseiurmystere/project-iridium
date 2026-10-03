namespace Iridium.Dialogs {
    /** Asks for audio files. Returns an empty array if dismissed. */
    public async File[] pick_files (Gtk.Window parent) {
        var filter = new Gtk.FileFilter () { name = _("Audio files") };
        filter.add_mime_type ("audio/*");
        var filters = new ListStore (typeof (Gtk.FileFilter));
        filters.append (filter);

        var dialog = new Gtk.FileDialog () { title = _("Open Audio Files"), filters = filters };
        File[] files = {};
        try {
            var list = yield dialog.open_multiple (parent, null);
            for (uint i = 0; i < list.get_n_items (); i++) {
                files += (File) list.get_item (i);
            }
        } catch (Error e) {
            AppLogger.debug_message ("open-files dismissed: " + e.message);
        }
        return files;
    }

    /** Asks for a folder. Returns an empty array if dismissed. */
    public async File[] pick_folder (Gtk.Window parent) {
        var dialog = new Gtk.FileDialog () { title = _("Open Folder") };
        File[] files = {};
        try {
            files += yield dialog.select_folder (parent, null);
        } catch (Error e) {
            AppLogger.debug_message ("open-folder dismissed: " + e.message);
        }
        return files;
    }

    /** Asks for a JPEG or PNG image. Returns null if dismissed. */
    public async File? pick_image (Gtk.Window parent) {
        var filter = new Gtk.FileFilter () { name = _("Images (JPEG, PNG)") };
        filter.add_mime_type ("image/jpeg");
        filter.add_mime_type ("image/png");
        var filters = new ListStore (typeof (Gtk.FileFilter));
        filters.append (filter);

        var dialog = new Gtk.FileDialog () { title = _("Choose Cover Image"), filters = filters };
        try {
            return yield dialog.open (parent, null);
        } catch (Error e) {
            AppLogger.debug_message ("pick-image dismissed: " + e.message);
            return null;
        }
    }
}
