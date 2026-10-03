/** A labelled text row; numeric helpers serve year/track fields. */
public class Iridium.TagFieldRow : Adw.EntryRow {
    public uint get_uint () {
        return uint.parse (text);
    }

    public void set_uint (uint value) {
        text = value == 0 ? "" : value.to_string ();
    }
}
