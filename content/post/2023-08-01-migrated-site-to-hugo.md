+++
author = "Mari Donkers"
title = "Migrated site to Hugo static site generator"
date = "2023-08-01"
description = "The site was previously generated using Hakyll. The new site uses the Hugo static site generator."
featured = false
tags = [
    "Computer",
    "Software",
    "Hugo",
    "Hakyll",
]
categories = [
    "static site generator",
]
series = ["Static Site Generators", "Hugo"]
aliases = ["2023-08-01-migrated-site-to-hugo"]
thumbnail = "/images/hugo.svg"
+++

The previous version of this site was generated using the [Hakyll](https://jaspervdj.be/hakyll/) static site generator. The new modernized site uses [Hugo](https://gohugo.io/) with the [Clarity](https://themes.gohugo.io/themes/hugo-clarity/) theme.
<!--more-->

# org-mode content
The [pandoc](https://pandoc.org/) program was used to convert the [org-mode](https://orgmode.org/) content to [Markdown](https://daringfireball.net/projects/markdown/).

```bash
#!/bin/sh

for ORG in *.org
do
  MD=`echo "${ORG}" | sed -e 's/^\(.*\).org$/\1.md/'`;
  pandoc -s --wrap=none -f org --toc -t gfm $1 -o "${MD}" "${ORG}";
  echo "${ORG} to ${MD}";
done
```
