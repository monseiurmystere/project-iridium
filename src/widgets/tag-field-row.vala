/**
 * A labelled text row. Numeric helpers serve the year/track fields: 0 means
 * "unset" and displays as empty, so a zero tag never shows a stray "0".
 */
public class Iridium.TagFieldRow : Adw.EntryRow {
    /** Parses the entry as uint; empty or invalid input yields 0. */
    public uint get_uint () {
        return uint.parse (text);
    }

    /** Shows @value, or empty when 0 (unset). */
    public void set_uint (uint value) {
        text = value == 0 ? "" : value.to_string ();
    }
}
