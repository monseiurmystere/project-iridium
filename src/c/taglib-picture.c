/* Thin wrapper over TagLib's complex-property API. The picture macro and the
 * nested pointer arrays are awkward from Vala, so they live here.
 *
 * Ownership: get returns a new GBytes (caller frees) and a new MIME string
 * (caller frees); both are copies, valid after the TagLib structures below
 * are released. set/clear return TagLib's success flag, not a GError. */
#include "taglib-picture.h"

GBytes *
iridium_taglib_get_picture (TagLib_File *file, char **mime_type)
{
  TagLib_Complex_Property_Attribute ***props;
  TagLib_Complex_Property_Picture_Data pic = { 0 };
  GBytes *bytes = NULL;

  *mime_type = NULL;
  props = taglib_complex_property_get (file, "PICTURE");
  if (props == NULL)
    return NULL;

  taglib_picture_from_complex_property (props, &pic);
  /* pic points into props, so copy before freeing below. Only the first
   * picture is used: v1 handles the front cover (or first image) only. */
  if (pic.data != NULL && pic.size > 0) {
    bytes = g_bytes_new (pic.data, pic.size);
    *mime_type = g_strdup (pic.mimeType != NULL && pic.mimeType[0] != '\0'
                           ? pic.mimeType : "application/octet-stream");
  }
  taglib_complex_property_free (props);
  return bytes;
}

/* Replaces every embedded picture with one front cover. Callers that never
 * loaded a cover must not call this: it would strip art it never saw. */
gboolean
iridium_taglib_set_picture (TagLib_File *file, GBytes *data,
                             const char *mime_type)
{
  gsize size;
  const char *bytes = g_bytes_get_data (data, &size);
  TAGLIB_COMPLEX_PROPERTY_PICTURE (props, bytes, (unsigned int) size,
                                   "", mime_type, "Front Cover");
  return taglib_complex_property_set (file, "PICTURE", props);
}

gboolean
iridium_taglib_clear_picture (TagLib_File *file)
{
  return taglib_complex_property_set (file, "PICTURE", NULL);
}
