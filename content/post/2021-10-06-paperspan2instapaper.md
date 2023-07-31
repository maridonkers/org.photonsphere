+++
author = "Mari Donkers"
title = "Paperspan export (HTML) to Instapaper import (CSV) convertor"
date = "2021-10-06"
description = "A Haskell program to convert the Paperspan HTML export format to an Instapaper CSV import format with automatic –configuration file driven– designation to folders. The HXT library is used to parse the Paperspan HTML file and the CSV result is written to standard output."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "YAML",
    "Regular Expression",
    "CSV",
    "HTML",
    "Internet",
]
categories = [
    "linux",
]
series = ["Haskell"]
aliases = ["2021-10-06-paperspan2instapaper"]
thumbnail = "/images/haskell.svg"
+++

A [Haskell](https://haskell.org) program to convert the [Paperspan](https://www.paperspan.com) HTML export format to an [Instapaper](https://instapaper.com) CSV import format with automatic –configuration file driven– designation to folders. The [HXT](https://wiki.haskell.org/HXT) library is used to parse the Paperspan HTML file and the CSV result is written to standard output.
<!--more-->

Usage: see the [Makefile](https://github.com/maridonkers/paperspan2instapaper/blob/master/Makefile).

# Paperspan format

``` html
<!DOCTYPE html>
<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>PaperSpan Export</title>
 </head>
 <body>
  <h1>Unread</h1>
  <ul>
   <h2>Read Later</h2>
   <ul>
     <li><a href="https://thisisalink" time_added="1630506259000">This is a <i>description</i>.</a></li>
     ...
   </ul>
  </ul>
...
  <h1>Read</h1>
 <ul>
  <h2>Read Later</h2>
  <ul>
    <li> ...</li>
    ...
  </ul>
 </ul>
</body>
```

# Paperspan folders

Existing Paperspan folders are reused by the conversion program. If the `Read Later` folder is encountered then an automatic designation to folders (via regular expression rules, which are provided in a configuration file) is done. See the next section for details on this.

# Automatic designation to folders

A [folders.yaml](https://github.com/maridonkers/paperspan2instapaper/blob/master/folders-example.yaml) configuration file, which contains Instapaper target folder names (for output file) and [regular expressions (PCRE)](https://github.com/niklongstone/regular-expression-cheat-sheet) for `URL` or `text` in Paperspan export (which is input). Each of the selector rules in the configuration file (I have hundreds) is matched against the URL or text of the Paperspan link being imported, until a match is found and an associated folder can be designated to it. This is very useful when you have a lot of unorganized links in your Paperspan (which you did not yet move to a folder).

e.g. the Paperspan link

``` html
<a href="https://news360.com/article/563394549"
   time_added="1630495255000">
  Stop prescribing hydroxychloroquine for Covid-19, warn researchers | Stop News – India TV
</a>
```

is matched with the following selector from [folders.yaml](https://github.com/maridonkers/paperspan2instapaper/blob/master/folders-example.yaml):

``` yaml
- "conditionRegExp": "\\bcovid-19\\b"
  "conditionSource": "text"
  "conditionFolderName": "biologyHealth"
```

which results in designation to the `Biology Health` folder via its folderName (also in [folders.yaml](https://github.com/maridonkers/paperspan2instapaper/blob/master/folders-example.yaml)).

``` yaml
- "folderName": "biologyHealth"
  "folderPath": "Biology Health"
```

and the following CSV line is the result:

``` bash
https://news360.com/article/563394549,
"Stop prescribing hydroxychloroquine for Covid-19, warn researchers | Stop News – India TV",
https://news360.com/article/563394549,
"Biology Health",
1630495255000
```

# GitHub

The source code for the convertor program is on GitHub: [maridonkers/paperspan2instapaper](https://github.com/maridonkers/paperspan2instapaper).

Disclaimer: this is a 'one shot' program (excuse my Haskell) that I've used only once to import an export of my *27,689* Paperspan article links into Instapaper. Update: still *2,140* undesignated links left; further refining program; adding more selector rules.

# Earlier

Earlier this [2019-02-18-instapaper-export](https://photonsphere.org/posts/2019-02-18-instapaper-export.html) was used for an Instpaper HTML export to Paperspan import.

(Hopping back and forth between these excellent read-later/archiving solutions.)
