/**
 * The application: locale and logging init, global actions (about, quit)
 * with accelerators, and single-window management. File opens from the CLI,
 * drag-and-drop handoff or "Open With" all funnel into Window.add_files.
 */
public class Iridium.Application : Adw.Application {
    /** Builds the app: ID, Open handling, resource path and CLI options. */
    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.HANDLES_OPEN,
            resource_base_path: "/co/tylr/Iridium"
        );
        add_main_option ("verbose", 'v', OptionFlags.NONE, OptionArg.NONE,
                         _("Enable debug logging"), null);
        handle_local_options.connect (on_local_options);
    }

    /**
     * Handles --verbose before GTK starts. Returning -1 continues normal
     * startup; the logger must be installed this early so app-start is
     * captured even in debug runs.
     */
    private int on_local_options (VariantDict options) {
        AppLogger.init (options.contains ("verbose"));
        return -1;
    }

    /**
     * One-time setup: locale for translations, UTF-8 ID3v2 default (so
     * Unicode tags survive a save), app actions and the startup log entry.
     */
    protected override void startup () {
        base.startup ();
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

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

    /** No-arg launch (or re-activate): present the single window. */
    protected override void activate () {
        window ().present ();
    }

    /** Files from argv or Open-With: queue them, then present. */
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
