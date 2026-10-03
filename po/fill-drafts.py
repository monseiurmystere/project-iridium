#!/usr/bin/env python3
"""Fills LLM-drafted translations into po/*.po. REVIEW REQUIRED before release.
Usage: fill-drafts.py (run from repo root)."""
import re
import sys
from pathlib import Path

PLURALS = {
    "fr": "nplurals=2; plural=(n > 1);",
    "es": "nplurals=2; plural=(n != 1);",
    "de": "nplurals=2; plural=(n != 1);",
}

TR = {
"fr": {
"Enable debug logging": "Activer les journaux de débogage",
"Iridium": "Iridium",
"Tyler": "Tyler",
"Edit audio file tags": "Modifier les tags des fichiers audio",
"Audio files": "Fichiers audio",
"Open Audio Files": "Ouvrir des fichiers audio",
"Open Folder": "Ouvrir un dossier",
"Images (JPEG, PNG)": "Images (JPEG, PNG)",
"Choose Cover Image": "Choisir une pochette",
"Image is larger than 10 MB": "L’image dépasse 10 Mo",
"Only JPEG and PNG images are supported": "Seuls les formats JPEG et PNG sont pris en charge",
"Cannot read image: %s": "Impossible de lire l’image : %s",
"Cannot read tags from %s": "Impossible de lire les tags de %s",
"Cannot read cover from %s": "Impossible de lire la pochette de %s",
"Cannot open %s": "Impossible d’ouvrir %s",
"%s does not support cover art": "%s ne prend pas en charge les pochettes",
"Cannot save %s (is it read-only?)": "Impossible d’enregistrer %s (est-il en lecture seule ?)",
"Saved %s": "%s enregistré",
"No Files Open": "Aucun fichier ouvert",
"Open audio files or drop them here to edit their tags.": "Ouvrez des fichiers audio ou déposez-les ici pour modifier leurs tags.",
"Open Files…": "Ouvrir des fichiers…",
"Open Folder…": "Ouvrir un dossier…",
"Unsaved changes": "Modifications non enregistrées",
"Files": "Fichiers",
"Open Files": "Ouvrir des fichiers",
"Tags": "Tags",
"About Iridium": "À propos d’Iridium",
"Quit": "Quitter",
"Save": "Enregistrer",
"Revert": "Annuler",
"Basic": "Général",
"Title": "Titre",
"Artist": "Artiste",
"Album": "Album",
"Genre": "Genre",
"Details": "Détails",
"Year": "Année",
"Track": "Piste",
"Comment": "Commentaire",
"Cover": "Pochette",
"Change…": "Modifier…",
"Remove": "Supprimer",
"Iridium is a native GNOME editor for ID3 and other audio tags. Open files or whole folders, edit titles, artists, albums and more, then save or revert your changes.": "Iridium est un éditeur de tags audio natif pour GNOME. Ouvrez des fichiers ou des dossiers entiers, modifiez titres, artistes, albums et bien plus, puis enregistrez ou annulez vos modifications.",
},
"es": {
"Enable debug logging": "Activar el registro de depuración",
"Iridium": "Iridium",
"Tyler": "Tyler",
"Edit audio file tags": "Editar las etiquetas de los archivos de audio",
"Audio files": "Archivos de audio",
"Open Audio Files": "Abrir archivos de audio",
"Open Folder": "Abrir carpeta",
"Images (JPEG, PNG)": "Imágenes (JPEG, PNG)",
"Choose Cover Image": "Elegir portada",
"Image is larger than 10 MB": "La imagen supera los 10 MB",
"Only JPEG and PNG images are supported": "Solo se admiten imágenes JPEG y PNG",
"Cannot read image: %s": "No se puede leer la imagen: %s",
"Cannot read tags from %s": "No se pueden leer las etiquetas de %s",
"Cannot read cover from %s": "No se puede leer la portada de %s",
"Cannot open %s": "No se puede abrir %s",
"%s does not support cover art": "%s no admite portadas",
"Cannot save %s (is it read-only?)": "No se puede guardar %s (¿es de solo lectura?)",
"Saved %s": "%s guardado",
"No Files Open": "Ningún archivo abierto",
"Open audio files or drop them here to edit their tags.": "Abra archivos de audio o suéltelos aquí para editar sus etiquetas.",
"Open Files…": "Abrir archivos…",
"Open Folder…": "Abrir carpeta…",
"Unsaved changes": "Cambios sin guardar",
"Files": "Archivos",
"Open Files": "Abrir archivos",
"Tags": "Etiquetas",
"About Iridium": "Acerca de Iridium",
"Quit": "Salir",
"Save": "Guardar",
"Revert": "Revertir",
"Basic": "Básicas",
"Title": "Título",
"Artist": "Artista",
"Album": "Álbum",
"Genre": "Género",
"Details": "Detalles",
"Year": "Año",
"Track": "Pista",
"Comment": "Comentario",
"Cover": "Portada",
"Change…": "Cambiar…",
"Remove": "Quitar",
"Iridium is a native GNOME editor for ID3 and other audio tags. Open files or whole folders, edit titles, artists, albums and more, then save or revert your changes.": "Iridium es un editor nativo de GNOME para etiquetas ID3 y otros audios. Abra archivos o carpetas enteras, edite títulos, artistas, álbumes y más, y luego guarde o revierta sus cambios.",
},
"de": {
"Enable debug logging": "Debug-Protokollierung aktivieren",
"Iridium": "Iridium",
"Tyler": "Tyler",
"Edit audio file tags": "Audio-Datei-Tags bearbeiten",
"Audio files": "Audiodateien",
"Open Audio Files": "Audiodateien öffnen",
"Open Folder": "Ordner öffnen",
"Images (JPEG, PNG)": "Bilder (JPEG, PNG)",
"Choose Cover Image": "Coverbild wählen",
"Image is larger than 10 MB": "Das Bild ist größer als 10 MB",
"Only JPEG and PNG images are supported": "Nur JPEG- und PNG-Bilder werden unterstützt",
"Cannot read image: %s": "Bild kann nicht gelesen werden: %s",
"Cannot read tags from %s": "Tags aus %s können nicht gelesen werden",
"Cannot read cover from %s": "Cover aus %s kann nicht gelesen werden",
"Cannot open %s": "%s kann nicht geöffnet werden",
"%s does not support cover art": "%s unterstützt keine Coverbilder",
"Cannot save %s (is it read-only?)": "%s kann nicht gespeichert werden (ist es schreibgeschützt?)",
"Saved %s": "%s gespeichert",
"No Files Open": "Keine Dateien geöffnet",
"Open audio files or drop them here to edit their tags.": "Öffnen Sie Audiodateien oder ziehen Sie sie hierher, um ihre Tags zu bearbeiten.",
"Open Files…": "Dateien öffnen…",
"Open Folder…": "Ordner öffnen…",
"Unsaved changes": "Ungespeicherte Änderungen",
"Files": "Dateien",
"Open Files": "Dateien öffnen",
"Tags": "Tags",
"About Iridium": "Über Iridium",
"Quit": "Beenden",
"Save": "Speichern",
"Revert": "Zurücksetzen",
"Basic": "Allgemein",
"Title": "Titel",
"Artist": "Künstler",
"Album": "Album",
"Genre": "Genre",
"Details": "Details",
"Year": "Jahr",
"Track": "Titelnummer",
"Comment": "Kommentar",
"Cover": "Cover",
"Change…": "Ändern…",
"Remove": "Entfernen",
"Iridium is a native GNOME editor for ID3 and other audio tags. Open files or whole folders, edit titles, artists, albums and more, then save or revert your changes.": "Iridium ist ein nativer GNOME-Editor für ID3- und andere Audio-Tags. Öffnen Sie Dateien oder ganze Ordner, bearbeiten Sie Titel, Künstler, Alben und mehr und speichern Sie Ihre Änderungen oder machen Sie sie rückgängig.",
},
}

PLURAL_TR = {
"fr": ("Impossible de lire %u fichier", "Impossible de lire %u fichiers"),
"es": ("No se pudo leer %u archivo", "No se pudieron leer %u archivos"),
"de": ("%u Datei konnte nicht gelesen werden", "%u Dateien konnten nicht gelesen werden"),
}

def unpo(s):
    return s.encode().decode("unicode_escape").encode("latin1").decode("utf-8")

def poesc(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')

def fill(path, lang):
    tr = TR[lang]
    lines = Path(path).read_text(encoding="utf-8").splitlines(keepends=True)
    out, i, missing = [], 0, []
    # Plural-Forms header
    lines = [l if not l.startswith('"Plural-Forms:') else
             f'"Plural-Forms: {PLURALS[lang]}\\n"' for l in lines]
    while i < len(lines):
        out.append(lines[i])
        m = re.match(r'^msgid "(.*)"\s*$', lines[i])
        if not m:
            i += 1
            continue
        msgid, i = m.group(1), i + 1
        while i < len(lines) and lines[i].startswith('"'):
            msgid += lines[i].strip()[1:-1]
            out.append(lines[i])
            i += 1
        key = unpo(msgid)
        if i < len(lines) and lines[i].startswith("msgid_plural"):
            while i < len(lines) and not lines[i].startswith("msgstr["):
                out.append(lines[i])  # keep msgid_plural + continuations
                i += 1
            s0, s1 = PLURAL_TR[lang]
            n = 0
            while i < len(lines) and lines[i].startswith("msgstr["):
                out.append(f'msgstr[{n}] "{poesc((s0, s1)[n])}"\n')
                n += 1
                i += 1
            continue
        if i < len(lines) and lines[i].startswith("msgstr"):
            if key == "":
                out.append(lines[i])  # header msgstr verbatim
                i += 1
                continue
            if key in tr:
                out.append(f'msgstr "{poesc(tr[key])}"\n')
            else:
                out.append(lines[i])
                missing.append(key)
            i += 1
    Path(path).write_text("".join(out), encoding="utf-8")
    # msgmerge resets the header: enforce real Plural-Forms afterwards.
    text = Path(path).read_text(encoding="utf-8")
    good = f'"Plural-Forms: {PLURALS[lang]}\\n"'
    if good not in text:
        text = re.sub(r'"Plural-Forms: [^\\n]*\\n?', good + "\n", text, count=1)
        if good not in text:  # header lacked the field entirely
            text = text.replace('"Content-Transfer-Encoding: 8bit\\n"',
                                '"Content-Transfer-Encoding: 8bit\\n"\n' + good, 1)
        Path(path).write_text(text, encoding="utf-8")
    print(f"{lang}: {len(tr) - len(missing)} translated, missing: {missing}")

if __name__ == "__main__":
    for lang in ["fr", "es", "de"]:
        fill(f"po/{lang}.po", lang)
