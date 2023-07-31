+++
author = "Mari Donkers"
title = "Random line from a text file"
date = "2018-08-28"
description = "About getting a random line from a text file in Clojure."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "IO",
    "Clojure",
]
categories = [
    "clojure",
]
series = ["Clojure"]
aliases = ["2018-08-28-random-line-from-text-file"]
thumbnail = "/images/clojure.svg"
+++

About getting a random line from a text file in [Clojure](http://clojure.org/).
<!--more-->

# Clojure code

``` clojure
(time (let [path "/usr/share/dict/american-english-insane"
            cnt (with-open [rdr (clojure.java.io/reader path)]
                  (count (line-seq rdr)))
            idx (int (rand cnt))
            word (with-open [rdr (clojure.java.io/reader path)]
                   (nth (line-seq rdr) idx))]
        (println (str "Word #" idx ": " word " (from " cnt " words)."))))
```

Word \#371611: kneecappings (from 650722 words). "Elapsed time: 201.590254 msecs"
