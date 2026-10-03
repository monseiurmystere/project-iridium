/**
 * An embedded picture: raw bytes plus MIME type. Bytes are kept as-is from
 * load to save (no re-encoding), so equality is a byte comparison.
 */
public class Iridium.CoverArt : Object {
    /** Original file bytes (JPEG or PNG). Shared by reference, never mutated. */
    public Bytes data { get; construct; }
    /** Sniffed at load time (see CoverArtService); written back on save. */
    public string mime_type { get; construct; }

    /** Wraps loaded @data with its @mime_type; both are stored by reference. */
    public CoverArt (Bytes data, string mime_type) {
        Object (data: data, mime_type: mime_type);
    }

    /**
     * Null-safe equality: two nulls are same, null vs cover is not.
     * Compares MIME type first (cheap) and bytes second.
     */
    public static bool same (CoverArt? a, CoverArt? b) {
        if (a == null || b == null) {
            return a == b;
        }
        return a.mime_type == b.mime_type && a.data.compare (b.data) == 0;
    }
}
