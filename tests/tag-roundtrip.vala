/** Writes tags to a synthetic MP3 and reads them back. */
void test_roundtrip () {
    string path;
    try {
        var fd = FileUtils.open_tmp ("iridium-XXXXXX.mp3", out path);
        FileUtils.close (fd);
        // Three MPEG1 Layer III 128kbps frames (header + zero padding).
        var frame = new uint8[417];
        frame[0] = 0xFF; frame[1] = 0xFB; frame[2] = 0x90; frame[3] = 0x00;
        uint8[] data = {};
        for (int i = 0; i < 3; i++) {
            foreach (var b in frame) {
                data += b;
            }
        }
        FileUtils.set_data (path, data);

        var audio = new Iridium.AudioFile (path, Iridium.TagReader.read (path));
        audio.tag.title = "Título";
        audio.tag.comment = "roundtrip comment";
        audio.tag.artist = "Artist";
        audio.tag.year = 2026;
        audio.tag.track = 3;
        assert (audio.dirty);
        Iridium.TagWriter.write (audio);
        assert (!audio.dirty);

        var back = Iridium.TagReader.read (path);
        assert (back.title == "Título");
        assert (back.artist == "Artist");
        assert (back.year == 2026);
        assert (back.track == 3);
        assert (back.comment == "roundtrip comment");
        FileUtils.remove (path);
    } catch (Error e) {
        Test.fail_printf ("%s", e.message);
    }
}

void test_revert () {
    var audio = new Iridium.AudioFile ("/tmp/x.mp3", new Iridium.AudioTag ());
    audio.tag.title = "changed";
    assert (audio.dirty);
    audio.revert ();
    assert (!audio.dirty);
}

const string PNG_B64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==";

string make_mp3 () throws Error {
    string path;
    FileUtils.close (FileUtils.open_tmp ("iridium-XXXXXX.mp3", out path));
    var frame = new uint8[417];
    frame[0] = 0xFF; frame[1] = 0xFB; frame[2] = 0x90;
    uint8[] data = {};
    for (int i = 0; i < 3; i++) {
        foreach (var b in frame) {
            data += b;
        }
    }
    FileUtils.set_data (path, data);
    return path;
}

Iridium.CoverArt png_cover () {
    return new Iridium.CoverArt (new Bytes (Base64.decode (PNG_B64)), "image/png");
}

void test_cover_roundtrip () {
    try {
        var path = make_mp3 ();
        var audio = new Iridium.AudioFile (path, Iridium.TagReader.read (path));
        audio.load_cover (Iridium.TagReader.read_cover (path));
        assert (audio.cover == null);
        assert (!audio.dirty);

        var cover = png_cover ();
        audio.replace_cover (cover);
        assert (audio.dirty);
        Iridium.TagWriter.write (audio);
        assert (!audio.dirty);

        var back = Iridium.TagReader.read_cover (path);
        assert (back != null);
        assert (Iridium.CoverArt.same (back, cover));

        audio.replace_cover (null);
        assert (audio.dirty);
        audio.revert ();
        assert (!audio.dirty && audio.cover != null);
        audio.replace_cover (null);
        Iridium.TagWriter.write (audio);
        assert (Iridium.TagReader.read_cover (path) == null);
        FileUtils.remove (path);
    } catch (Error e) {
        Test.fail_printf ("%s", e.message);
    }
}

void test_unloaded_cover_untouched () {
    try {
        var path = make_mp3 ();
        var first = new Iridium.AudioFile (path, Iridium.TagReader.read (path));
        first.load_cover (null);
        first.replace_cover (png_cover ());
        Iridium.TagWriter.write (first);

        // Never loads its cover, so saving must not drop the picture.
        var second = new Iridium.AudioFile (path, Iridium.TagReader.read (path));
        second.tag.title = "x";
        Iridium.TagWriter.write (second);
        assert (Iridium.TagReader.read_cover (path) != null);
        FileUtils.remove (path);
    } catch (Error e) {
        Test.fail_printf ("%s", e.message);
    }
}

void test_cover_service_limits () {
    try {
        string path;
        FileUtils.close (FileUtils.open_tmp ("iridium-XXXXXX.png", out path));
        var file = File.new_for_path (path);

        FileUtils.set_data (path, Base64.decode (PNG_B64));
        assert (Iridium.CoverArtService.load (file).mime_type == "image/png");

        FileUtils.set_contents (path, "plain text, not an image");
        try {
            Iridium.CoverArtService.load (file);
            Test.fail_printf ("text file accepted");
        } catch (Iridium.TagError e) {
        }

        var big = new uint8[Iridium.CoverArtService.MAX_BYTES + 1];
        FileUtils.set_data (path, big);
        try {
            Iridium.CoverArtService.load (file);
            Test.fail_printf ("oversized file accepted");
        } catch (Iridium.TagError e) {
        }
        FileUtils.remove (path);
    } catch (Error e) {
        Test.fail_printf ("%s", e.message);
    }
}

int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/tag/roundtrip", test_roundtrip);
    Test.add_func ("/tag/revert", test_revert);
    Test.add_func ("/cover/roundtrip", test_cover_roundtrip);
    Test.add_func ("/cover/unloaded-untouched", test_unloaded_cover_untouched);
    Test.add_func ("/cover/service-limits", test_cover_service_limits);
    return Test.run ();
}
