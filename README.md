# emacs-doc

Machine translation of the GNU Emacs manuals into Japanese with [PLaMo Translate](https://translate.preferredai.jp/), served at <https://emacs-doc.conao3.com>.

This is a personal project and is not affiliated with the Free Software Foundation, the GNU Project, or Preferred Networks.

## Manuals

| Directory | Manual | Source |
|---|---|---|
| `emacs/` | GNU Emacs Manual | `doc/emacs/emacs.texi` |
| `elisp/` | GNU Emacs Lisp Reference Manual | `doc/lispref/elisp.texi` |
| `eintr/` | An Introduction to Programming in Emacs Lisp | `doc/lispintro/emacs-lisp-intro.texi` |

Each manual is also available as one page in `mono/<manual>.html`.

The manuals follow the master branch of [Emacs](https://github.com/emacs-mirror/emacs). `EMACS_REVISION` records the commit the translations were last merged with.

## How it works

1. `make fetch-latest` checks out the `doc` directory of the Emacs master branch and writes its commit to `EMACS_REVISION`. `make fetch` checks out the commit already in `EMACS_REVISION`.
2. `make html` builds each manual with `makeinfo --html` twice: one page per node in `<manual>/`, and the whole manual in one page in `mono/<manual>.html`.
3. `make pot` extracts the text of every page with po4a (`xhtml`) into one catalog per manual and merges it into `po/<manual>.ja.po` with `msgmerge --previous`. Both versions of a manual share the catalog; a paragraph whose links differ between them (`Node.html` and `#Node`) is a separate entry. A paragraph whose English changed becomes fuzzy; a new paragraph is untranslated.
4. `make translate` fills the untranslated and fuzzy machine-translated entries with [po-plamo](https://github.com/conao3/rust-po-plamo). Code (`code`, `kbd`, `pre`, `samp`, `var`) is kept in English, and entries extracted from `pre`, `style`, and `script` are not translated. `LIMIT=<n>` stops after n msgids.
5. `make site` writes the translated pages to `dist/` with `po4a --keep 0`, so a paragraph without a translation stays in English. Each page gets a notice that links to the original page on gnu.org (`html_node` or `html_mono`).
6. `make deploy` uploads `dist/` to the Cloudflare Worker `emacs-doc` (static assets) with wrangler.

`make stats` prints the translated and untranslated counts of each catalog.

The `Update` workflow is run by hand (`gh workflow run update.yml`). It runs every step except `make translate`, commits the updated `po/*.ja.po`, and deploys the site, so a new or changed paragraph stays in English until `make translate` is run locally and the catalogs are pushed. It needs these repository secrets:

| Secret | Value |
|---|---|
| `CLOUDFLARE_API_TOKEN` | A Cloudflare API token with Workers Scripts edit on the account and Workers Routes edit on the zone of the custom domain. |
| `CLOUDFLARE_ACCOUNT_ID` | The Cloudflare account ID. |

## Correcting a translation

Edit the `msgstr` in `po/<manual>.ja.po` and delete the line `# Machine-translated by PLaMo Translate.` of that entry. po-plamo does not overwrite entries without that line, and a fuzzy entry without it is left for a person to review.

## Development

```console
$ nix develop
$ make fetch site
$ make check
```

`make check` runs `nix fmt -- --ci`, shellcheck on `scripts/`, and `msgfmt --check-format` on the catalogs.

## License

The manuals and their translations (`po/`, and the generated site) are distributed under the GNU Free Documentation License, version 1.3 or later (`COPYING.FDL`), the same license as the original manuals. The scripts and configuration are Apache-2.0 (`LICENSE`).
