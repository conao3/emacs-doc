#!/usr/bin/env bash
# Build the Emacs, Emacs Lisp, and Emacs Lisp Intro manuals as HTML, one file per node
# in <out>/<manual>/ and one file per manual in <out>/mono/<manual>.html.
set -euo pipefail

emacs=$1
out=$2

version=$(sed -n 's/^AC_INIT(\[GNU Emacs\], \[\([^]]*\)\].*/\1/p' "$emacs/configure.ac")
if [ -z "$version" ]; then
  echo "could not read the Emacs version from $emacs/configure.ac" >&2
  exit 1
fi
sed "s/@version@/$version/" "$emacs/doc/emacs/emacsver.texi.in" >"$emacs/doc/emacs/emacsver.texi"

build() {
  local manual=$1 texi=$2
  rm -rf "${out:?}/$manual" "$out/mono/$manual.html"
  mkdir -p "$out/$manual" "$out/mono"
  makeinfo --html --force --enable-encoding \
    -I "$emacs/doc/emacs" -I "$(dirname "$texi")" \
    -o "$out/$manual" "$texi"
  makeinfo --html --no-split --force --enable-encoding \
    -I "$emacs/doc/emacs" -I "$(dirname "$texi")" \
    -o "$out/mono/$manual.html" "$texi"
}

build emacs "$emacs/doc/emacs/emacs.texi"
build elisp "$emacs/doc/lispref/elisp.texi"
build eintr "$emacs/doc/lispintro/emacs-lisp-intro.texi"
cp "$emacs"/doc/lispintro/*.png "$out/eintr/"
cp "$emacs"/doc/lispintro/*.png "$out/mono/"
echo "$version" >"$out/VERSION"
