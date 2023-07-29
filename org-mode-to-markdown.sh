#!/bin/sh

for ORG in *.org
do
  MD=`echo "${ORG}" | sed -e 's/^\(.*\).org$/\1.md/'`;
  pandoc -s --wrap=none -f org --toc -t gfm $1 -o "${MD}" "${ORG}";
  echo "${ORG} to ${MD}";
done
