+++
author = "Mari Donkers"
title = "Combine several PDF-files into one"
date = "2014-12-16"
description = "Ever wanted to combine several PDF-files into a single file?"
featured = false
tags = [
    "Computer",
    "Software",
    "Linux",
    "PDF",
]
categories = [
    "linux",
]
series = ["Linux"]
aliases = ["2014-12-16-combine-several-pdf-files-info-one"]
thumbnail = "images/linux.jpg"
+++

—- title: Combine several PDF-files into one modified: 2014-12-16 meta<sub>description</sub>: tags: Computer, Linux, PDF, Software, Shell Script —-

Ever wanted to combine several PDF-files into a single file? Under Linux a simple command can be used to accomplish this.

(.more.)

Use the command given below:

``` bash
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=output.pdf input1.pdf input2.pdf
```

(Note: this requires ghostscript to be installed.)
