all: site

shell:
	nix-shell

edit:
	nix-shell --run emacs &

hlint:
	nix-shell --run "hlint site.hs"

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
