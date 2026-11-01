#!/usr/bin/env bash
# Build the Emacs, Emacs Lisp, and Emacs Lisp Intro manuals as HTML, one file per node.
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
  rm -rf "${out:?}/$manual"
  mkdir -p "$out/$manual"
  makeinfo --html --force --enable-encoding \
    -I "$emacs/doc/emacs" -I "$(dirname "$texi")" \
    -o "$out/$manual" "$texi"
}

build emacs "$emacs/doc/emacs/emacs.texi"
build elisp "$emacs/doc/lispref/elisp.texi"
build eintr "$emacs/doc/lispintro/emacs-lisp-intro.texi"
cp "$emacs"/doc/lispintro/*.png "$out/eintr/"
echo "$version" >"$out/VERSION"
