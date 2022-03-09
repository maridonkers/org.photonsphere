all: help

shell:
	nix-shell

# To build for production use `make -B prod`
prod: build _site/css/site.css

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

rebuild: site
	./site build

build: site
	./site build

tailwind-dev: build
	npx tailwindcss -i ./site.css -o ./_site/css/site.css --watch

_site/css/site.css:
	NODE_ENV=production npx tailwindcss -i ./site.css -o ./_site/css/site.css --minify

check: build
	./site -v check

server: build
	./site -v server

watch: build
	./site -v watch

clean:
	./site -v clean

upload:
	(cd _site ; lftp -u ftp@donkersautomatisering.nl --env-password -e "mirror -R -n -v .; bye" ftp.donkersautomatisering.nl/domains/photonsphere.org/public_html)

help:
	@grep '^[^ 	#:]\+:' Makefile | sed -e 's/:[^:]*//g'
	@echo -e "\nRun make shell prior to building site.hs.\n"
