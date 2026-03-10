COLLECTIONS = pkgsrc-core.txt \
	      pkgsrc-system.txt \
	      pkgsrc-xorg.txt \
	      pkgsrc-desktop.txt \
	      pkgsrc-wmaker.txt \
	      pkgsrc-games.txt \
	      pkgsrc-stuff.txt

all:
	@echo ""
	@echo "Targets:"
	@echo "  check-dups:       check for duplicated urls"
	@echo "  check-missing:    check for missing feeds"
	@echo "  check-redundant:  check for redundant feeds"
	@echo "  check-urls:       check for dead urls"
	@echo "  gen-newsraft:     generate newsraft feeds file"
	@echo "  gen-snownews:     generate snownews OPML file"
	@echo "  sort-pkgsrcs:     sort collection packages by name"
	@echo ""
	@echo "Collections:"
	@echo "  $(COLLECTIONS)"
	@echo

check-dups: $(COLLECTIONS) bin/check-dups.pl
	@bin/check-dups.pl $(COLLECTIONS)

check-missing: $(COLLECTIONS) bin/check-missing.pl
	@bin/check-missing.pl $(COLLECTIONS)

check-redundant: $(COLLECTIONS) bin/check-redundant.pl
	@bin/check-redundant.pl $(COLLECTIONS)

check-urls: $(COLLECTIONS) bin/check-urls.sh
	@HTTPX=0 bin/check-urls.sh $(COLLECTIONS)

gen-newsraft: $(COLLECTIONS) bin/gen-newsraft.pl
	@echo "GEN newsraft"
	@bin/gen-newsraft.pl $(COLLECTIONS) > newsraft

gen-snownews: $(COLLECTIONS) bin/gen-snownews.pl
	@echo "GEN snownews.opml"
	@bin/gen-snownews.pl $(COLLECTIONS) > snownews.opml

sort-pkgsrcs: $(COLLECTIONS) bin/sort-pkgsrcs.pl
	@for f in $(COLLECTIONS); do \
		bin/sort-pkgsrcs.pl $$f > $$f.new; \
		diff -pruN --color=always $$f $$f.new | cat -ET; \
		mv -i $$f.new $$f; \
	done

