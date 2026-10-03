/**
 * Central logging. Events go to the systemd journal (visible in GNOME Logs
 * and `journalctl -t co.tylr.Iridium`); stderr is the fallback, e.g. in
 * sandboxes without a journal socket. Only basenames are logged at INFO and
 * above; full paths appear in DEBUG messages.
 */
namespace Iridium.AppLogger {
    public const string IDENT = "co.tylr.Iridium";
    private bool verbose = false;

    public void init (bool debug) {
        verbose = debug || Environment.get_variable ("G_MESSAGES_DEBUG") != null;
        Log.set_writer_func (write);
    }

    /** Records a user-visible action (INFO). */
    public void action (string name, string detail = "") {
        log_structured (IDENT, LogLevelFlags.LEVEL_INFO,
            "SYSLOG_IDENTIFIER", IDENT,
            "IRIDIUM_ACTION", name,
            "MESSAGE", "%s", detail == "" ? name : "%s: %s".printf (name, detail));
    }

    /** Records a failure (WARNING). @path is reduced to its basename. */
    public void error (string code, string message, string? path = null) {
        log_structured (IDENT, LogLevelFlags.LEVEL_WARNING,
            "SYSLOG_IDENTIFIER", IDENT,
            "CODE", code,
            "IRIDIUM_FILE", path != null ? Path.get_basename (path) : "",
            "MESSAGE", "%s", "%s: %s".printf (code, message));
        debug_message ("%s full path: %s".printf (code, path ?? "-"));
    }

    /** Opt-in detail (--verbose or G_MESSAGES_DEBUG). */
    public void debug_message (string message) {
        log_structured (IDENT, LogLevelFlags.LEVEL_DEBUG,
            "SYSLOG_IDENTIFIER", IDENT,
            "MESSAGE", "%s", message);
    }

    private LogWriterOutput write (LogLevelFlags level, LogField[] fields) {
        if ((level & LogLevelFlags.LEVEL_DEBUG) != 0 && !verbose) {
            return LogWriterOutput.HANDLED;
        }
        var sent = Log.writer_journald (level, fields);
        // Mirror to the terminal during development, or fall back to it.
        if (sent != LogWriterOutput.HANDLED || Posix.isatty (2)) {
            return Log.writer_standard_streams (level, fields);
        }
        return LogWriterOutput.HANDLED;
    }
}
