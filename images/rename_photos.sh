#!/usr/bin/env bash
#
# rename_photos.sh
# Renames 20 photos to descriptive filenames and lowercases all extensions to .jpg
#
# Usage:
#   ./rename_photos.sh                 # dry run (shows what would happen, no changes)
#   ./rename_photos.sh --execute       # actually performs the renames
#   ./rename_photos.sh -d /path/to/dir # run against a specific directory
#
# Safe by default: dry-run unless --execute is passed.
# Will not overwrite existing files (uses mv -n).

set -euo pipefail

# ---- defaults ----
DIR="."
EXECUTE=0

# ---- arg parsing ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute|-y) EXECUTE=1; shift ;;
    -d|--dir)     DIR="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

cd "$DIR"

# ---- mapping: "oldname|newname" (newname always ends in .jpg, lowercase) ----
mapping=(
  "photo-1.jpg|inside-barrel-underwater-blue.jpg"
  "photo-2.jpg|aerial-tropical-beach-converging-waves.jpg"
  "photo-3.jpg|summit-tent-star-trails-valley-lights.jpg"
  "photo-4.jpg|alpine-hut-headlamp-starry-night.jpg"
  "photo-5.jpg|sri-lanka-surfer-stupa-palms.jpg"
  "photo-6.JPG|surfer-barrel-offshore-spray.jpg"
  "photo-7.jpg|alpine-snowboarder-vast-mountain-vista.jpg"
  "photo-8.JPG|snowboarder-hiking-capita-board-flare.jpg"
  "photo-9.jpg|snowboarder-sunset-ridge-camp.jpg"
  "photo-10.JPG|surfer-rocky-coastline-small-wave.jpg"
  "photo-11.jpg|star-trails-mountain-lake-rocks.jpg"
  "photo-12.JPG|tropical-palm-shoreline-from-water.jpg"
  "photo-13.JPG|crashing-blue-wave-water-level.jpg"
  "photo-14.JPG|clear-wave-bokeh-sunlight.jpg"
  "photo-15.jpg|wavegarden-aerial-surf-pool.jpg"
  "photo-16.jpg|long-exposure-abstract-wave-sunset.jpg"
  "photo-17.jpg|surfer-wetsuit-turquoise-barrel.jpg"
  "photo-18.JPG|aerial-sandy-beach-cliffs-turquoise.jpg"
  "photo-19.JPG|small-glassy-green-wave-pastel-sky.jpg"
  "photo-20.jpg|snowboarder-powder-spray-steep-slope.jpg"
)

if [[ $EXECUTE -eq 0 ]]; then
  echo "DRY RUN (no files will be changed). Re-run with --execute to apply."
  echo "Working directory: $(pwd)"
  echo "---"
fi

renamed=0
skipped_missing=0
skipped_conflict=0

for entry in "${mapping[@]}"; do
  old="${entry%%|*}"
  new="${entry##*|}"

  if [[ ! -f "$old" ]]; then
    echo "SKIP (missing): $old"
    skipped_missing=$((skipped_missing+1))
    continue
  fi

  if [[ -e "$new" && "$old" != "$new" ]]; then
    echo "SKIP (target exists): $old -> $new"
    skipped_conflict=$((skipped_conflict+1))
    continue
  fi

  if [[ $EXECUTE -eq 1 ]]; then
    mv -n -- "$old" "$new"
    echo "RENAMED: $old -> $new"
  else
    echo "WOULD RENAME: $old -> $new"
  fi
  renamed=$((renamed+1))
done

echo "---"
echo "Done. processed=$renamed, missing=$skipped_missing, conflicts=$skipped_conflict"
if [[ $EXECUTE -eq 0 ]]; then
  echo "(dry run, no changes made)"
fi
exit 0
