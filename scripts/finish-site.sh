#!/usr/bin/env bash
# Mark the translated pages as Japanese, add the machine translation notice
# that links to the original page, and copy the images and the top page.
set -euo pipefail

html=$1
dist=$2
revision=$3

version=$(cat "$html/VERSION")
short=${revision:0:10}

for manual in emacs elisp eintr; do
  for page in "$dist/$manual"/*.html; do
    name=$(basename "$page")
    original="https://www.gnu.org/software/emacs/manual/html_node/$manual/$name"
    notice="<div class=\"mt-notice\" lang=\"ja\" style=\"border:1px solid #c9c9c9;background:#fafaf5;padding:.5em .8em;margin:0 0 1em;font-size:.9em\">GNU Emacs $version (<a href=\"https://github.com/emacs-mirror/emacs/commit/$revision\">$short</a>) のマニュアルを PLaMo 翻訳で機械翻訳したものです。誤訳を含むことがあります。原文: <a href=\"$original\" lang=\"en\">$original</a> ・ <a href=\"/\">emacs-doc.conao3.com</a></div>"
    sed -i \
      -e 's|^<html>$|<html lang="ja">|' \
      -e "s|^<body lang=\"en\">\$|<body lang=\"ja\">\n$notice|" \
      "$page"
  done
done
cp "$html"/eintr/*.png "$dist/eintr/"
sed -e "s|@VERSION@|$version|g" -e "s|@REVISION@|$revision|g" -e "s|@SHORT_REVISION@|$short|g" \
  site/index.html >"$dist/index.html"
