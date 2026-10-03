public class Iridium.Application : Adw.Application {
    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.HANDLES_OPEN,
            resource_base_path: "/co/tylr/Iridium"
        );
        add_main_option ("verbose", 'v', OptionFlags.NONE, OptionArg.NONE,
                         "Enable debug logging", null);
        handle_local_options.connect (on_local_options);
    }

    private int on_local_options (VariantDict options) {
        AppLogger.init (options.contains ("verbose"));
        return -1;
    }

    protected override void startup () {
        base.startup ();
        TagLib.ID3v2.set_default_text_encoding (TagLib.ID3v2.Encoding.UTF8);

        var about = new SimpleAction ("about", null);
        about.activate.connect (() => Dialogs.show_about (active_window));
        add_action (about);

        var quit = new SimpleAction ("quit", null);
        quit.activate.connect (() => quit_app ());
        add_action (quit);

        set_accels_for_action ("app.quit", { "<Control>q" });
        set_accels_for_action ("win.open-files", { "<Control>o" });
        set_accels_for_action ("win.open-folder", { "<Control><Shift>o" });
        set_accels_for_action ("win.save", { "<Control>s" });
        set_accels_for_action ("win.revert", { "<Control>r" });

        AppLogger.action ("app-start", "version=" + Config.VERSION);
    }

    protected override void activate () {
        window ().present ();
    }

    protected override void open (File[] files, string hint) {
        var win = window ();
        win.add_files (files);
        win.present ();
    }

    private void quit_app () {
        AppLogger.action ("app-quit");
        quit ();
    }

    private Window window () {
        return (active_window as Window) ?? new Window (this);
    }
}
