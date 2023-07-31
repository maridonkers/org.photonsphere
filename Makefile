all: help

develop:
	nix-shell

edit:
	emacs &

build: 
	hugo

server:
	hugo server --disableFastRender

clean:
	rm -rf public

upload:
	(cd _site ; lftp -u ftp@donkersautomatisering.nl --env-password -e "mirror -R -n -v .; bye" ftp.donkersautomatisering.nl/domains/photonsphere.org/public_html)

help:
	@grep '^[^ 	#:]\+:' Makefile | sed -e 's/:[^:]*//g'
