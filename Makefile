all: help

shell:
	nix-shell

edit:
	nix-shell --run emacs &

lint:
	nix-shell --run "hlint site.hs"

formatter:
	nix-shell --run "stylish-haskell -i site.hs"

clean-site: clean
	rm -f ./site

site:
	nix-shell --run "ghc --make site.hs"

build: site
	nix-shell --run "./site build"

check: build
	nix-shell --run "./site check"

server: build
	nix-shell --run "./site server"

clean:
	nix-shell --run "./site clean"

upload:
	(cd _site ; lftp -u ftp@donkersautomatisering.nl --env-password -e "mirror -R -n -v .; bye" ftp.donkersautomatisering.nl/domains/photonsphere.org/public_html)

help:
	@grep '^[^ 	#:]\+:' Makefile | sed -e 's/:[^:]*//g'
