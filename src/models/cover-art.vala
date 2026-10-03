/** An embedded picture: raw bytes plus MIME type. */
public class Iridium.CoverArt : Object {
    public Bytes data { get; construct; }
    public string mime_type { get; construct; }

    public CoverArt (Bytes data, string mime_type) {
        Object (data: data, mime_type: mime_type);
    }

    /** Null-safe equality. */
    public static bool same (CoverArt? a, CoverArt? b) {
        if (a == null || b == null) {
            return a == b;
        }
        return a.mime_type == b.mime_type && a.data.compare (b.data) == 0;
    }
}
