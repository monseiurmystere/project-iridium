#!/usr/bin/env bash
# Generates Iridium manual-test fixtures. See doc/10-test-plan.md.
# Usage: make-fixtures.sh [OUTPUT_DIR] [--stress]
# Requires: ffmpeg with libmp3lame, aac, flac and libopus encoders
# (Fedora's ffmpeg-free qualifies; otherwise use tools/onboard.sh --with-rpmfusion).
set -euo pipefail

OUT="${1:-/tmp/iridium-fixtures}"
STRESS=0
if [[ "${2:-}" == "--stress" ]]; then STRESS=1; fi

command -v ffmpeg >/dev/null || { echo "error: ffmpeg is required" >&2; exit 1; }
# Capture first: grep -q closes the pipe early, which trips pipefail via SIGPIPE.
FFMPEG_ENCODERS="$(ffmpeg -hide_banner -encoders 2>/dev/null)"
missing_enc=()
for enc in libmp3lame aac flac libopus; do
    grep -q "$enc" <<<"$FFMPEG_ENCODERS" || missing_enc+=("$enc")
done
if [[ "${#missing_enc[@]}" -gt 0 ]]; then
    echo "error: ffmpeg lacks encoders: ${missing_enc[*]}" >&2
    echo "Fedora: tools/onboard.sh --with-rpmfusion for the full build." >&2
    exit 1
fi

rm -rf "$OUT"
mkdir -p "$OUT/nested/a/b" "$OUT/images"

tone() { # tone <freq> <outfile> [extra ffmpeg args...]
    local freq="$1" out="$2"; shift 2
    ffmpeg -v error -y -f lavfi -i "sine=frequency=$freq:duration=2" \
        -c:a libmp3lame -q:a 5 "$@" "$out"
}

echo "--- images ---"
ffmpeg -v error -y -f lavfi -i "testsrc=size=300x300:duration=1" \
    -frames:v 1 "$OUT/images/cover.png"
ffmpeg -v error -y -f lavfi -i "testsrc=size=300x300:duration=1" \
    -frames:v 1 "$OUT/images/cover.jpg"
head -c 100 "$OUT/images/cover.png" > "$OUT/images/corrupt.png"
echo "plain text, not an image" > "$OUT/images/not-image.png"
# Valid PNG magic, but over the 10 MB limit (tests size rejection, not type).
{ printf '\x89PNG\r\n\x1a\n'; head -c $((10 * 1024 * 1024 + 1)) /dev/zero; } \
    > "$OUT/images/big.png"

echo "--- mp3 ---"
tone 440 "$OUT/plain.mp3"
tone 550 "$OUT/tagged.mp3" \
    -metadata title="Título Ünïcodé" \
    -metadata artist="Test Artist" \
    -metadata album="Test Album" \
    -metadata genre="Jazz" \
    -metadata date="2026" \
    -metadata track="3" \
    -metadata comment="fixture comment"
# tagged.mp3 with an embedded front cover.
ffmpeg -v error -y -i "$OUT/tagged.mp3" -i "$OUT/images/cover.png" \
    -map 0 -map 1 -c copy -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
    "$OUT/tagged-cover.mp3" && mv "$OUT/tagged-cover.mp3" "$OUT/tagged.mp3"
: > "$OUT/empty.mp3"
echo "this is not audio" > "$OUT/fake.mp3"
head -c 400 "$OUT/plain.mp3" > "$OUT/truncated.mp3"
cp "$OUT/plain.mp3" "$OUT/readonly.mp3" && chmod 444 "$OUT/readonly.mp3"

echo "--- nested ---"
tone 660 "$OUT/nested/one.mp3"
tone 770 "$OUT/nested/a/two.mp3"
tone 880 "$OUT/nested/a/b/three.mp3"

echo "--- other formats (best-effort) ---"
ffmpeg -v error -y -f lavfi -i "sine=frequency=440:duration=2" \
    -c:a flac -metadata title="FLAC Title" "$OUT/song.flac" || echo "skip: flac"
ffmpeg -v error -y -f lavfi -i "sine=frequency=440:duration=2" \
    -c:a aac -metadata title="M4A Title" "$OUT/song.m4a" || echo "skip: m4a"
ffmpeg -v error -y -f lavfi -i "sine=frequency=440:duration=2" \
    -c:a libopus "$OUT/song.opus" || echo "skip: opus"

if [[ "$STRESS" == "1" ]]; then
    echo "--- stress (500 files) ---"
    mkdir -p "$OUT/stress"
    for i in $(seq -w 1 500); do cp "$OUT/plain.mp3" "$OUT/stress/f$i.mp3"; done
fi

audio_hash() { # audio_hash <file>: hash of the encoded audio packets only.
    ffmpeg -v error -i "$1" -map 0:a -c copy -f md5 - 2>/dev/null || echo "n/a"
}
{
    echo "# Reference audio hashes (tags/covers must not change these)."
    for f in "$OUT"/tagged.mp3 "$OUT"/plain.mp3 "$OUT"/song.flac "$OUT"/song.m4a; do
        [[ -f "$f" ]] && echo "$(audio_hash "$f")  $(basename "$f")"
    done
} > "$OUT/audio-hashes.txt"

echo "--- manifest ---"
find "$OUT" -type f | sort
echo "Fixtures in $OUT"
