#ifndef IRIDIUM_TAGLIB_PICTURE_H
#define IRIDIUM_TAGLIB_PICTURE_H

#include <glib.h>
#include <tag_c.h>

/* Returns the first embedded picture (NULL if none) and its MIME type. */
GBytes *iridium_taglib_get_picture (TagLib_File *file, char **mime_type);

/* Replaces all embedded pictures with a single front cover. */
gboolean iridium_taglib_set_picture (TagLib_File *file, GBytes *data,
                                     const char *mime_type);

/* Removes all embedded pictures. */
gboolean iridium_taglib_clear_picture (TagLib_File *file);

#endif
