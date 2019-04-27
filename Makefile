SUBMAKES_REQUIRED=logo/ist theme/ist
SUBMAKES_EXTRA=example/ist
SUBMAKES_TEST=
SUBMAKES=$(SUBMAKES_REQUIRED) $(SUBMAKES_EXTRA) $(SUBMAKES_TEST)
.PHONY: all base complete docs clean dist dist-implode implode \
	install install-base install-docs uninstall tests $(SUBMAKES)

BASETHEMEFILE=beamerthemefibeamer.sty
OTHERTHEMEFILES=theme/ist/*.sty
THEMEFILES=$(BASETHEMEFILE) $(OTHERTHEMEFILES)
LOGOSOURCES=logo/*/*.pdf
LOGOS=logo/*/*.eps
DTXFILES=*.dtx theme/ist/*.dtx
INSFILES=*.ins theme/ist/*.ins
TESTS=
MAKES=Makefile guide/ist/Makefile theme/ist/Makefile logo/ist/Makefile
USEREXAMPLE_SOURCES=example/ist/Makefile example/ist/example.dtx \
	example/ist/*.ins
USEREXAMPLES=example/ist/dei-lualatex.pdf example/ist/dei-pdflatex.pdf
DEVEXAMPLES=logo/DESCRIPTION logo/EXAMPLE/DESCRIPTION \
	logo/mu/DESCRIPTION theme/EXAMPLE/DESCRIPTION \
	theme/mu/DESCRIPTION theme/DESCRIPTION example/DESCRIPTION \
	example/EXAMPLE/DESCRIPTION example/mu/DESCRIPTION \
	example/mu/resources/DESCRIPTION guide/DESCRIPTION \
	guide/EXAMPLE/DESCRIPTION guide/mu/DESCRIPTION \
	guide/mu/resources/DESCRIPTION test/DESCRIPTION \
	test/EXAMPLE/DESCRIPTION test/mu/DESCRIPTION
EXAMPLES=$(USEREXAMPLES) $(DEVEXAMPLES)
MISCELLANEOUS=guide/ist/guide.bib \
	guide/ist/guide.dtx guide/ist/*.ins guide/ist/resources/cog.pdf \
    guide/ist/resources/vader.pdf guide/ist/resources/yoda.pdf \
	$(USEREXAMPLES:.pdf=.tex) \
	example/ist/resources/jabberwocky-dark.pdf \
	example/ist/resources/jabberwocky-light.pdf README.md
RESOURCES=$(THEMEFILES) $(LOGOS) $(LOGOSOURCES)
SOURCES=$(DTXFILES) $(INSFILES) LICENSE.tex
AUXFILES=fibeamer.aux fibeamer.log fibeamer.toc fibeamer.ind \
	fibeamer.idx fibeamer.out fibeamer.ilg fibeamer.gls \
	fibeamer.glo fibeamer.hd
MANUAL=fibeamer.pdf
PDFSOURCES=fibeamer.dtx
PDFS=$(MANUAL) $(USEREXAMPLES)
DOCS=$(MANUAL)
VERSION=VERSION.tex
TDSARCHIVE=fibeamer.tds.zip
CTANARCHIVE=fibeamer.ctan.zip
DISTARCHIVE=fibeamer.zip
ARCHIVES=$(TDSARCHIVE) $(CTANARCHIVE) $(DISTARCHIVE)
MAKEABLES=$(MANUAL) $(BASETHEMEFILE) $(ARCHIVES) $(VERSION)

TEXLIVEDIR=$(shell kpsewhich -var-value TEXMFLOCAL)

# This is the default pseudo-target.
all: base

# This pseudo-target expands all the docstrip files, converts the
# logos and creates the theme files.
base: $(SUBMAKES_REQUIRED)
	make $(BASETHEMEFILE)

# This pseudo-target creates the class files and typesets the
# technical documentation, the user guides, and the user examples.
complete: base
	make $(PDFS) clean

# This pseudo-target typesets the technical documentation and the
# user guides.
docs:
	make $(DOCS) clean

# This pseudo-target calls a submakefile.
$(SUBMAKES):
	make -C $@ all

# This pseudo-target performs the tests.
tests: base $(SUBMAKES_TEST)

# This pseudo-target creates the distribution archive.
dist: dist-implode complete
	make $(TDSARCHIVE) $(DISTARCHIVE) $(CTANARCHIVE)

# This target creates the theme files.
$(BASETHEMEFILE): fibeamer.ins fibeamer.dtx
	xetex $<

# This target typesets the guides and user examples.
$(GUIDES) $(USEREXAMPLES): $(RESOURCES)
	make -BC $(dir $@)

# This target typesets the technical documentation.
$(MANUAL): $(DTXFILES)
	pdflatex $<
	pdflatex $<
	makeindex -s gind.ist                       $(basename $@)
	makeindex -s gglo.ist -o $(basename $@).gls $(basename $@).glo
	pdflatex $<
	pdflatex $<

# This target generates a TeX directory structure file.
$(TDSARCHIVE):
	DIR=`mktemp -d` && \
	make install to="$$DIR" nohash=true && \
	(cd "$$DIR" && zip -r -v -nw $@ *) && \
	mv "$$DIR"/$@ $@ && rm -rf "$$DIR"

# This target generates a distribution file.
$(DISTARCHIVE): $(SOURCES) $(RESOURCES) $(MAKES) $(TESTS) \
	$(USEREXAMPLE_SOURCES) $(DOCS) $(PDFSOURCES) $(MISCELLANEOUS) \
	$(EXAMPLES) $(VERSION)
	DIR=`mktemp -d` && \
	cp --verbose $(TDSARCHIVE) "$$DIR" && \
	cp --parents --verbose $^ "$$DIR" && \
	(cd "$$DIR" && zip -r -v -nw $@ *) && \
	mv "$$DIR"/$@ . && rm -rf "$$DIR"

# This target generates a CTAN distribution file.
$(CTANARCHIVE): $(SOURCES) $(MAKES) $(TESTS) $(EXAMPLES) \
	$(MISCELLANEOUS) $(DOCS) $(VERSION) $(LOGOSOURCES)
	DIR=`mktemp -d` && mkdir -p "$$DIR/fibeamer" && \
	cp --verbose $(TDSARCHIVE) "$$DIR" && \
	cp --parents --verbose $^ "$$DIR/fibeamer" && \
	printf '.PHONY: implode\nimplode:\n' > \
		"$$DIR/fibeamer/example/mu/Makefile" && \
	(cd "$$DIR" && zip -r -v -nw $@ *) && \
	mv "$$DIR"/$@ . && rm -rf "$$DIR"

# This pseudo-target installs the logo and theme files - as well as
# the technical documentation and user guides - into the TeX
# directory structure, whose root directory is specified within the
# "to" argument.  Specify "nohash=true", if you wish to forgo the
# reindexing of the package database.
install: install-base install-docs

# This pseudo-target installs the logo and theme files into the TeX
# directory structure, whose root directory is specified within the
# "to" argument.  Specify "nohash=true", if you wish to forgo the
# reindexing of the package database.
install-base:
	@if [ -z "$(to)" ]; then \
		printf "Usage: make install-base to=DIRECTORY\n"; \
		printf "Detected TeXLive directory: %s\n" $(TEXLIVEDIR); \
		exit 1; \
	fi
	
	@# Theme and logo files
	mkdir -p "$(to)/tex/latex/fibeamer"
	cp --parents --verbose $(RESOURCES) "$(to)/tex/latex/fibeamer"
	
	@# Source files
	mkdir -p "$(to)/source/latex/fibeamer"
	cp --parents --verbose $(SOURCES) "$(to)/source/latex/fibeamer"
	
	@# Rebuild the hash
	[ "$(nohash)" = "true" ] || texhash

# This pseudo-target installs the technical documentation and user
# guides into the TeX directory structure, whose root directory is
# specified within the "to" argument.  Specify "nohash=true", if
# you wish to forgo the reindexing of the package database.
install-docs:
	@if [ -z "$(to)" ]; then \
		printf "Usage: make install-docs to=DIRECTORY\n"; \
		printf "Detected TeXLive directory: %s\n" $(TEXLIVEDIR); \
		exit 1; \
	fi
	
	@# Documentation
	mkdir -p "$(to)/doc/latex/fibeamer"
	cp --parents --verbose $(DOCS) "$(to)/doc/latex/fibeamer"
	
	@# Rebuild the hash
	[ "$(nohash)" = "true" ] || texhash

# This pseudo-target uninstalls the logo and theme files - as well
# as the technical documentation and user guides - into the TeX
# directory structure, whose root directory is specified within the
# "from" argument.  Specify "nohash=true", if you wish to forgo the
# reindexing of the package database.
uninstall:
	@if [ -z "$(from)" ]; then \
		printf "Usage: make uninstall from=DIRECTORY\n"; \
		printf "Detected TeXLive directory: %s\n" $(TEXLIVEDIR); \
		exit 1; \
	fi
	
	@# Theme and logo files
	rm -rf "$(from)/tex/latex/fibeamer"
	
	@# Source files
	rm -rf "$(from)/source/latex/fibeamer"
	
	@# Documentation
	rm -rf "$(from)/doc/latex/fibeamer"
	
	@# Rebuild the hash
	[ "$(nohash)" = "true" ] || texhash

# This pseudo-target removes any existing auxiliary files.
clean:
	rm -f $(AUXFILES)

# This pseudo-target removes the distribution archives.
dist-implode:
	rm -f $(ARCHIVES)

# This pseudo-target removes any makeable files.
implode: clean
	rm -f $(MAKEABLES)
	for dir in $(SUBMAKES); do make implode -C "$$dir"; done
