# org-mode
Batch [convert](https://blog.mikecordell.com/2019/04/14/bulk-org-mode-to-github-flavored-markdown/) from [org-mode](https://orgmode.org/) to [Markdown](https://daringfireball.net/projects/markdown/) (using [pandoc](https://pandoc.org/)):

```bash
#! /bin/bash

SRC="./blog"
DEST="/Users/michael/Library/Mobile Documents/com~apple~CloudDocs/blog"

SRC_ESCAPED=$(echo $SRC | sed -e 's/\.\//\\.\\\//g')
DEST_ESCAPED=$(echo $DEST | sed -e 's/\//\\\//g')

STATEMENT="s/^$SRC_ESCAPED/$DEST_ESCAPED/"

# Create mirror'd folder structure at destination
find "$SRC" -type d -exec sh -c 'echo $1 | sed -e "$0" | xargs -I}{ mkdir -p "}{"' "$STATEMENT" {} \;

# Convert each org file to markdown in the destination folder structure
find "$SRC" -iregex ".*org" -exec sh -c 'echo $1 | sed -e "s/\.org$/\.md/" -e "$0" | xargs -I}{ pandoc -s --wrap=none -f org --toc -t gfm $1 -o }{' "$STATEMENT" {} \;
```

# hugoBasicExample

This repository offers an example site for [Hugo](https://gohugo.io/) and also it provides the default content for demos hosted on the [Hugo Themes Showcase](https://themes.gohugo.io/).

# Using

1. [Install Hugo](https://gohugo.io/overview/installing/)
2. Clone this repository
```bash
git clone https://github.com/gohugoio/hugoBasicExample.git
cd hugoBasicExample
```
3. Clone the repository you want to test. If you want to test all Hugo Themes then follow the instructions provided [here](https://github.com/gohugoio/hugoThemes#installing-all-themes)
4. Run Hugo and select the theme of your choosing
```bash
hugo server -t YOURTHEME
```
5. Under `/content/` this repository contains the following:
- A section called `/post/` with sample markdown content
- A headless bundle called `homepage` that you may want to use for single page applications. You can find instructions about headless bundles over [here](https://gohugo.io/content-management/page-bundles/#headless-bundle)
- An `about.md` that is intended to provide the `/about/` page for a theme demo
6. If you intend to build a theme that does not fit in the content structure provided in this repository, then you are still more than welcome to submit it for review at the [Hugo Themes](https://github.com/gohugoio/hugoThemes/issues) respository

# Brave browser

tut — Jun '22
I have observed some strange issue with `Hugo` whether on (blank) new sites or existing sites. I use `Brave` browser and if no permalinks are defined in the config file, the single pages enter into the Quirks Mode and the layout/stylesheets are broken. Everything else works properly on Firefox (I have only tested both browsers). I am not sure why the layout breaks.

If anyone comes across this issue, the `speed reader` option in Brave is to blame. Turn it off in settings!

[Page goes into Quirks Mode if no permalinks are defined](https://discourse.gohugo.io/t/page-goes-into-quirks-mode-if-no-permalinks-are-defined/39291)

* git

To clone including submodules (e.g. themes), use `--recurse-submodules`.

```sh
git clone --recurse-submodules <repository>
```
