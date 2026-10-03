[CCode (cheader_filename = "taglib-picture.h")]
namespace IridiumTagLib {
    [CCode (cname = "iridium_taglib_get_picture")]
    public GLib.Bytes? get_picture (TagLib.File file, out string? mime_type);

    [CCode (cname = "iridium_taglib_set_picture")]
    public bool set_picture (TagLib.File file, GLib.Bytes data, string mime_type);

    [CCode (cname = "iridium_taglib_clear_picture")]
    public bool clear_picture (TagLib.File file);
}
