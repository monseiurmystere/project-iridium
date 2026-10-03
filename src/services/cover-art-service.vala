namespace Iridium.CoverArtService {
    /** Rejection threshold: covers are kept byte-for-byte, so cap the RAM cost. */
    public const int64 MAX_BYTES = 10 * 1024 * 1024;

    /**
     * Loads a JPEG or PNG from @file without re-encoding it.
     *
     * The size is checked before reading (no giant allocation), and the type
     * is sniffed from magic bytes rather than the extension. Anything else —
     * missing file, oversize, non-image — becomes TagError.COVER with a
     * message safe to show in a toast. Decoding is NOT validated here; an
     * undecodable file surfaces later as a placeholder (see CoverArtWidget).
     */
    public CoverArt load (File file) throws TagError {
        try {
            var info = file.query_info ("standard::size", FileQueryInfoFlags.NONE);
            if (info.get_size () > MAX_BYTES) {
                throw new TagError.COVER (_("Image is larger than 10 MB"));
            }
            var data = file.load_bytes (null, null);
            var type = ContentType.guess (null, data.get_data (), null);
            if (type != "image/jpeg" && type != "image/png") {
                throw new TagError.COVER (_("Only JPEG and PNG images are supported"));
            }
            return new CoverArt (data, type);
        } catch (Error e) {
            // Our own TagError values already carry user-facing messages;
            // anything else (GIO failures) is wrapped, never leaked raw.
            if (e is TagError) {
                throw (TagError) e;
            }
            throw new TagError.COVER (_("Cannot read image: %s"), e.message);
        }
    }
}
