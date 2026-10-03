namespace Iridium.Dialogs {
    private struct AboutInfo {
        string app_name;
        string developer;
        string comments;
        string copyright;
        string website;
        string issue_url;
    }

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

    /** Reads data/about.json from GResources; hardcoded fallback on failure. */
    private AboutInfo load_about_info () {
        var info = AboutInfo () {
            app_name = "Iridium",
            developer = "Tyler",
            comments = "Edit audio file tags",
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
            info.app_name = obj.get_string_member_with_default ("application-name", info.app_name);
            info.developer = obj.get_string_member_with_default ("developer-name", info.developer);
            info.comments = obj.get_string_member_with_default ("comments", info.comments);
            info.copyright = obj.get_string_member_with_default ("copyright", info.copyright);
            info.website = obj.get_string_member_with_default ("website", info.website);
            info.issue_url = obj.get_string_member_with_default ("issue-url", info.issue_url);
        } catch (Error e) {
            AppLogger.error ("about-load-failed", e.message);
        }
        return info;
    }
}
