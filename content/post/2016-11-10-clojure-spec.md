+++
author = "Mari Donkers"
title = "clojure.spec"
date = "2016-11-10"
description = "Specification is much more powerful than static typing plus you also get validation, instrumentation and generative testing – clojure.spec"
featured = false
tags = [
    "Computer",
    "Software",
    "Testing",
    "Functional Programming",
    "Clojure",
    "ClojureScript",
]
categories = [
    "clojure",
]
series = ["Clojure"]
aliases = ["2016-11-10-clojure-spec"]
thumbnail = "/images/clojure.svg"
+++

Specification is much more powerful than static typing plus you also get validation, instrumentation and generative testing – [clojure.spec](http://clojure.org/about/spec) (by **Rich Hickey**)
<!--more-->

# Example (spec for URIs)

``` clojure
(ns example.specs
  (:require #?(:clj  [clojure.spec :as s]
               :cljs [cljs.spec :as s])
            [clojure.string :as str]))
;; URI spec.
(def uri?
  (s/and string? #?(:clj #(try (do (java.net.URI. %) true) (catch Exception e false))
                    :cljs #(= (str/replace (js/encodeURI %) "%25" "%") %))))
;; e.g. Call as follows:
(s/valid? uri? "https://www.google.nl/url?q=https://www.reddit.com/r/Clojure/comments/4kutl7/clojurespec_guide/&sa=U&ved=0ahUKEwic2v3-r6DQAhVBGsAKHcrVCZMQFggUMAA&usg=AFQjCNHs0DmF1uNIw9BYUK7pqpgp5HEbow")
```

# Videos

- [Introducing clojure.spec](https://youtu.be/CVO0M8CTV78) (by Arne Brasseur);
- [Agility & Robustness: Clojure spec](https://youtu.be/VNTQ-M_uSo8) (by Stuart Halloway);
- [Clojure spec Screencast: Leverage](https://youtu.be/nqY4nUMfus8) (by Stuart Halloway);
- [Clojure spec Screencast: Testing](https://youtu.be/W6crrbF7s2s); (by Stuart Halloway)
- [Clojure spec Screencast: Customizing Generators](https://youtu.be/WoFkhE92fqc) (by Stuart Halloway);
- [Introduction to clojure.spec](https://youtu.be/TD7VGSSZ3ng) (by Lambda Island);
- [clojure.spec](https://youtu.be/Rlu-X5AqWXw) (by David Nolen).
