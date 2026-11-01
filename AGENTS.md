# AGENTS.md

`emacs-doc` builds the Japanese machine translation of the GNU Emacs manuals served at https://emacs-doc.conao3.com. The pipeline and the repository secrets are described in `README.md`.

## Layout

- `Makefile`: the pipeline (`fetch`, `fetch-latest`, `html`, `pot`, `translate`, `site`, `stats`, `deploy`, `check`).
- `scripts/`: `fetch-emacs.sh` (sparse checkout of `doc/` and `configure.ac`), `build-html.sh` (makeinfo), `po4a-config.sh` (one po4a configuration per manual), `finish-site.sh` (language attribute, notice, images, top page).
- `site/index.html`: the top page. `@VERSION@`, `@REVISION@`, and `@SHORT_REVISION@` are replaced by `finish-site.sh`.
- `po/<manual>.ja.po`: the translations, committed. `po/*.pot` and `build/` are regenerated and ignored.
- `wrangler.jsonc`: the Worker `emacs-doc` with static assets from `dist/` and the custom domain `emacs-doc.conao3.com`.

## Conventions

- Machine translations carry `# Machine-translated by PLaMo Translate.`; entries without it are human translations and must not be overwritten.
- po4a runs with `--porefs noline` so that line numbers in the HTML do not change the catalogs, and with `--keep 0` so that every page is written.
- Commit messages, comments, and docs are in English.

## Verification

```console
$ nix develop --command make check
$ nix develop --command make fetch site
$ nix build
```

`make fetch site` needs no credentials. Open `dist/index.html` or run `wrangler dev` to look at the result. `make translate` needs `PLAMO_AUTH_FILE`; use `LIMIT=<n>` for a short run.
