MANUALS := emacs elisp eintr
EMACS_DIR := build/emacs
HTML_DIR := build/html
DIST_DIR := dist
SKIP_CONTEXT := <(pre|style|script)>
PO4A_FLAGS := --porefs noline --wrap-po no --msgmerge-opt=--previous --keep 0

.PHONY: all
all: site

# Check out the Emacs revision in EMACS_REVISION.
.PHONY: fetch
fetch:
	scripts/fetch-emacs.sh $(EMACS_DIR) "$$(cat EMACS_REVISION)"

# Move EMACS_REVISION to the tip of the Emacs master branch.
.PHONY: fetch-latest
fetch-latest:
	scripts/fetch-emacs.sh $(EMACS_DIR) master
	git -C $(EMACS_DIR) rev-parse HEAD > EMACS_REVISION

.PHONY: html
html:
	scripts/build-html.sh $(EMACS_DIR) $(HTML_DIR)

# Extract the msgids from the HTML manuals into po/*.pot and merge po/*.ja.po.
.PHONY: pot
pot: html
	for manual in $(MANUALS); do \
	  scripts/po4a-config.sh $$manual $(HTML_DIR) $(DIST_DIR) > build/po4a-$$manual.cfg && \
	  po4a $(PO4A_FLAGS) --no-translations build/po4a-$$manual.cfg || exit 1; \
	done

# Fill po/*.ja.po with PLaMo Translate. Set LIMIT to stop after that many msgids.
.PHONY: translate
translate:
	po-plamo --source en --format html --skip-context '$(SKIP_CONTEXT)' \
	  $(if $(LIMIT),--limit $(LIMIT)) $(foreach manual,$(MANUALS),po/$(manual).ja.po)

.PHONY: site
site: html
	rm -rf $(DIST_DIR)
	for manual in $(MANUALS); do \
	  scripts/po4a-config.sh $$manual $(HTML_DIR) $(DIST_DIR) > build/po4a-$$manual.cfg && \
	  po4a $(PO4A_FLAGS) --no-update build/po4a-$$manual.cfg || exit 1; \
	done
	scripts/finish-site.sh $(HTML_DIR) $(DIST_DIR) "$$(cat EMACS_REVISION)"

.PHONY: stats
stats:
	for manual in $(MANUALS); do \
	  printf '%s: ' $$manual; msgfmt --statistics -o /dev/null po/$$manual.ja.po; \
	done

.PHONY: deploy
deploy:
	wrangler deploy

.PHONY: check
check:
	nix fmt -- --ci
	shellcheck scripts/*.sh
	for manual in $(MANUALS); do msgfmt --check-format -o /dev/null po/$$manual.ja.po || exit 1; done

.PHONY: clean
clean:
	rm -rf build $(DIST_DIR)
