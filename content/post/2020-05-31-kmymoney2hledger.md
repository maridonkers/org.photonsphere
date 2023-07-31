+++
author = "Mari Donkers"
title = "KMyMoney to HLedger"
date = "2020-05-31"
description = "Because I have been wanting to start using plain text accounting I needed a conversion from KMyMoney software to HLedger."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "Financial",
    "Plain Text Accounting",
    "CSV",
    "XML",
]
categories = [
    "haskell",
    "financial",
]
series = ["Haskell", "Financial"]
aliases = ["2020-05-31-kmymoney2hledger"]
thumbnail = "/images/ledger.svg"
+++

Because I have been wanting to start using [plain text accounting](https://plaintextaccounting.org/) I needed a conversion from [KMyMoney](https://kmymoney.org/) software to [HLedger](https://hledger.org/).
<!--more-->

# WAIT!

Just use [isabekov / kmymoney2ledgers](https://github.com/isabekov/kmymoney2ledgers) by [Altynbek Isabekov](https://github.com/isabekov) instead of my conversion program! (It's much better!)

# Command line Clojure tool

My Clojure [KMyMoney to HLedger conversion](https://github.com/maridonkers/kmymoney2hledger) conversion program (a quick hack; also see disclaimer in the source code header) uses `Tupolo
Forest` (see below) to parse the input XML KMyMoney file (prior to conversion it must be decompressed from its gzip format).

# Usage

From [Releases](https://github.com/maridonkers/kmymoney2hledger/releases) copy `kmymoney2hledger` and `kmymoney2hledger.jar` to a subdirectory and make `kmymoney2hledger` executable. Put the subdirectory in your path (if it isn't already). Also a Java runtime environment (JRE) is required.

``` bash
kmymoney2hledger yourdecompressedkmymoneyinputfile.kmy
```

It writes the converted output to

``` bash
yourdecompressedkmymoneyinputfile.kmy.journal
```

# CSV importers

See the following repositories for import of CSV-files into HLedger journals:

[Rabobank CSV-export to HLedger converter](https://github.com/maridonkers/rabobankcsvhledger) and [N26 CSV-export to HLedger converter](https://github.com/maridonkers/n26csvhledger)

But it's much better to use the HLedger [csv format](https://hledger.org/csv.html) functionality to import CSV-files.

# Technical information

## Libraries

Have you ever wanted to manipulate tree-like data structures such as hiccup or HTML? If so, then the tupelo.forest library is for you! Forest allows you to:

- Easily search for tree nodes based on the path from the tree root.
- Search for tree nodes based on content.
- Limit a search to nodes in an arbitrary sub-tree.
- Find parents and siblings of a node found in a search.
- Chain searches together, so that nodes found in one search are used to limit the scope of sub-searches.
- In addition, tupelo.forest allows you to update the tree by adding, changing, or deleting nodes. Since tupelo.forest allows one to easily find parent and/or sibling nodes, this is a powerful feature missing in most other tree-processing libraries. – [Tupelo Forest](https://github.com/cloojure/tupelo/blob/master/docs/forest.adoc) (by [Alan Thompson](https://github.com/clojure))
