/**
 * Failures surfaced to the user as toasts (and to the journal). Messages are
 * translated at the throw site; Codes stay English for log greppability.
 */
public errordomain Iridium.TagError {
    /** File cannot be opened or its tags cannot be read. */
    OPEN,
    /** Tags cannot be written (permissions, read-only media, no cover support). */
    SAVE,
    /** A chosen cover image is unusable (type, size, unreadable). */
    COVER
}
