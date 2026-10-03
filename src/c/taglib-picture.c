/* Thin wrapper over TagLib's complex-property API. The picture macro and the
 * nested pointer arrays are awkward from Vala, so they live here. */
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
  if (pic.data != NULL && pic.size > 0) {
    bytes = g_bytes_new (pic.data, pic.size);
    *mime_type = g_strdup (pic.mimeType != NULL && pic.mimeType[0] != '\0'
                           ? pic.mimeType : "application/octet-stream");
  }
  taglib_complex_property_free (props);
  return bytes;
}

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
