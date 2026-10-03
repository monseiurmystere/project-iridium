namespace Iridium.Dialogs {
    public void show_about (Gtk.Window? parent) {
        var dialog = new Adw.AboutDialog () {
            application_name = "Iridium",
            application_icon = Config.APP_ID,
            developer_name = "Tyler",
            version = Config.VERSION,
            comments = "Edit audio file tags",
            license_type = Gtk.License.GPL_3_0,
        };
        dialog.present (parent);
    }
}
