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

int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/tag/roundtrip", test_roundtrip);
    Test.add_func ("/tag/revert", test_revert);
    return Test.run ();
}
