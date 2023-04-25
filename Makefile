TAILWINDCSS = "$(HOME)/bin/tailwindcss"

all: help

develop:
	nix-shell

# To build for production use `make -B prod`
prod: rebuild _site/css/site.css

edit:
	emacs &

lint:
	hlint site.hs

formatter:
	stylish-haskell -i site.hs

clean-site: clean
	cabal clean

site:
	cabal build
	# ghc --make site.hs

rebuild: site
	rm -rf _site
	cabal run . -- rebuild

build: site
	cabal run . -- build

tailwind-dev: build
	$(TAILWINDCSS) -i ./site.css -o ./_site/css/site.css --watch

_site/css/site.css:
	NODE_ENV=production $(TAILWINDCSS) -i ./site.css -o ./_site/css/site.css --minify

check: build
	cabal run . --  -v check

server: build
	cabal run . --  server

watch: build
	cabal run . --  -v watch

clean:
	cabal run . --  -v clean

upload:
	(cd _site ; lftp -u ftp@donkersautomatisering.nl --env-password -e "mirror -R -n -v .; bye" ftp.donkersautomatisering.nl/domains/photonsphere.org/public_html)

help:
	@grep '^[^ 	#:]\+:' Makefile | sed -e 's/:[^:]*//g'
	@echo -e "\nRun make shell prior to building site.hs.\n"
