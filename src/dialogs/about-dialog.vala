namespace Iridium.Dialogs {
    /** Decoded About content: display strings from JSON, identity from Config. */
    private struct AboutInfo {
        string app_name;
        string developer;
        string comments;
        string copyright;
        string website;
        string issue_url;
    }

    /**
     * Presents the About dialog. Empty website/issue-url stay hidden rather
     * than showing blank rows.
     */
    public void show_about (Gtk.Window? parent) {
        var info = load_about_info ();
        var dialog = new Adw.AboutDialog () {
            application_name = info.app_name,
            application_icon = Config.APP_ID,
            developer_name = info.developer,
            version = Config.VERSION,
            comments = info.comments,
            copyright = info.copyright,
            license_type = Gtk.License.GPL_3_0,
        };
        if (info.website != "") {
            dialog.website = info.website;
        }
        if (info.issue_url != "") {
            dialog.issue_url = info.issue_url;
        }
        dialog.present (parent);
    }

    /**
     * Reads data/about.json from GResources and translates its display
     * strings; falls back to translated hardcoded defaults when the resource
     * is missing or corrupt (logged, never silent).
     * The _() literals below double as xgettext extraction hints: keep them
     * in sync with data/about.json.
     */
    private AboutInfo load_about_info () {
        var info = AboutInfo () {
            app_name = _("Codename: Iridium"),
            developer = _("Ashleigh Clark"),
            comments = _("A simple application designed to edit audio information for supported files. Album art is also supported here."),
            copyright = "",
            website = "",
            issue_url = ""
        };
        try {
            var bytes = resources_lookup_data ("/co/tylr/Iridium/data/about.json",
                                               ResourceLookupFlags.NONE);
            var parser = new Json.Parser ();
            parser.load_from_data ((string) bytes.get_data (), (ssize_t) bytes.length);
            var obj = parser.get_root ().get_object ();
            info.app_name = _(obj.get_string_member_with_default ("application-name", "Codename: Iridium"));
            info.developer = _(obj.get_string_member_with_default ("developer-name", "Ashleigh Clark"));
            info.comments = _(obj.get_string_member_with_default ("comments", "A simple application designed to edit audio information for supported files. Album art is also supported here."));
            info.copyright = obj.get_string_member_with_default ("copyright", info.copyright);
            info.website = obj.get_string_member_with_default ("website", info.website);
            info.issue_url = obj.get_string_member_with_default ("issue-url", info.issue_url);
        } catch (Error e) {
            AppLogger.error ("about-load-failed", e.message);
        }
        return info;
    }
}
