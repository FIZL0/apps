#!/usr/bin/env bash
# build.sh [OUT] — one sideloading source (AltStore v2: AltStore, SideStore, Feather) for every FIZL0 iOS app.
# Each app's own release ships an altstore-source.json; this merges their apps into OUT/source.json.
# An app joins by adding its repo to REPOS once its releases carry that file; repos without one are skipped.
set -euo pipefail
REPOS=(opentennis openmx partyboard)
out=${1:-_site}
mkdir -p "$out"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
for r in "${REPOS[@]}"; do
  curl -fsL "https://github.com/FIZL0/$r/releases/latest/download/altstore-source.json" -o "$tmp/$r.json" \
    || { echo "skip $r: no altstore-source.json in its latest release" >&2; rm -f "$tmp/$r.json"; }
done
jq -s '{ name: "FIZL0", identifier: "io.github.fizl0", sourceURL: "https://fizl0.github.io/apps/source.json",
         website: "https://fizl0.github.io/apps/", subtitle: "Open remasters by FIZL0",
         apps: (map(.apps) | add // []), news: (map(.news // []) | add // []) }' "$tmp"/*.json >"$out/source.json"
cp index.html "$out/"
jq -r '.apps[] | "\(.name) \(.version)"' "$out/source.json"
