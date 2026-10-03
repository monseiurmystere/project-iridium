namespace Iridium.CoverArtService {
    public const int64 MAX_BYTES = 10 * 1024 * 1024;

    /** Loads a JPEG or PNG from @file; throws TagError.COVER if unusable. */
    public CoverArt load (File file) throws TagError {
        try {
            var info = file.query_info ("standard::size", FileQueryInfoFlags.NONE);
            if (info.get_size () > MAX_BYTES) {
                throw new TagError.COVER ("Image is larger than 10 MB");
            }
            var data = file.load_bytes (null, null);
            var type = ContentType.guess (null, data.get_data (), null);
            if (type != "image/jpeg" && type != "image/png") {
                throw new TagError.COVER ("Only JPEG and PNG images are supported");
            }
            return new CoverArt (data, type);
        } catch (Error e) {
            if (e is TagError) {
                throw (TagError) e;
            }
            throw new TagError.COVER ("Cannot read image: %s", e.message);
        }
    }
}
