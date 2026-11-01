#!/usr/bin/env bash
# Check out the doc directory of Emacs at a revision (a commit or "master").
set -euo pipefail

dir=$1
revision=$2

if [ ! -d "$dir/.git" ]; then
  git init --quiet "$dir"
  git -C "$dir" remote add origin https://github.com/emacs-mirror/emacs.git
  git -C "$dir" sparse-checkout set --no-cone '/doc/' '/configure.ac'
fi
git -C "$dir" fetch --quiet --depth 1 --filter=blob:none origin "$revision"
git -C "$dir" checkout --quiet --detach FETCH_HEAD
git -C "$dir" log -1 --format='Emacs %H (%cs)'
