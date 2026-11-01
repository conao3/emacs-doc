#!/usr/bin/env bash
# Print a po4a configuration that maps every HTML node of a manual to one PO file.
set -euo pipefail

manual=$1
html=$2
dist=$3

cat <<EOF
[po4a_langs] ja
[po4a_paths] po/$manual.pot \$lang:po/$manual.\$lang.po
[options] opt:"-M utf-8 -L utf-8 -o attributes=title"
EOF
for file in "$html/$manual"/*.html; do
  echo "[type: xhtml] $file \$lang:$dist/$manual/$(basename "$file")"
done
