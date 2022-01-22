all: help

shell:
	nix-shell

edit:
	emacs &

lint:
	hlint site.hs

formatter:
	stylish-haskell -i site.hs

clean-site: clean
	rm -f ./site

site:
	ghc --make site.hs

build: site
	./site build

check: build
	./site check

server: build
	./site server

clean:
	./site clean

upload:
	(cd _site ; lftp -u ftp@donkersautomatisering.nl --env-password -e "mirror -R -n -v .; bye" ftp.donkersautomatisering.nl/domains/photonsphere.org/public_html)

help:
	@grep '^[^ 	#:]\+:' Makefile | sed -e 's/:[^:]*//g'
	@echo -e "\nRun make shell prior to building site.hs.\n"
