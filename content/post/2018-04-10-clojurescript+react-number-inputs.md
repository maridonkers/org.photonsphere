+++
author = "Mari Donkers"
title = "ClojureScript+React number inputs"
date = "2018-04-14"
description = "When using ClojureScript with a React library **beware** that the `:value` for an `:input` needs to be of type string. If this is not the case then screen updates initiated from the code sometimes fail."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Internet",
    "JavaScript",
    "HTML",
    "Client",
    "GUI",
    "Clojure",
    "ClojureScript",
]
categories = [
    "clojure",
]
series = ["Clojure"]
aliases = ["2018-04-10-clojurescript+react-number-inputs "]
thumbnail = "/images/react.svg"
+++

When using [ClojureScript](http://clojurescript.org/) with a React library **beware** that the `:value` for an `:input` needs to be of type string. If this is not the case then screen updates initiated from the code sometimes fail.
<!--more-->

# Demonstration of the issue

I've used [Rum](https://github.com/tonsky/rum) for a demonstration of the issue –not suggesting that this is Rum specific (haven't tried this with other ClojureScript React libraries).

If one takes the correct [Rum examples](https://github.com/tonsky/rum/blob/gh-pages/examples/rum/examples/inputs.cljc) code, in which the type is correctly converted to a string via a `(str value)`, as shown below:

``` clojure
(rum/defc reactive-input < rum/reactive
  [*ref]
  (let [value (rum/react *ref)]
    [:input { :type "text"
              :value (str value)
              :style { :width 170 }
              :on-change (fn [e] (reset! *ref (long (.. e -currentTarget -value)))) }]))
```

And change this correct code, omitting the `(str ..)`, as follows:

``` clojure
:value value
```

And do a `lein cljsbuild once` to compile the code and then load the index.html file in the browser.

Then the text field is not always updated when its value is set in the ClojureScript code. In the Rum example this is when –in the inputs box– clecking a checkbox, clicking a radio button, selecting a dropdown element, clicking the Next value button.

# Screen dump

![](/images/Rum-input-non-string-demo.png)

Note in the `Inputs` box (first colum, middle row) the value for `Input` (which is `1`) and the `Checks`, `Radio`, `Select` and `Next
value` (which indicate `3`).

Normally (with the `(str value)` in place) these inputs would always be synchronized and show the same value.

# Older React versions

This update issue appears not to occur with older React versions, for example:

``` clojure
[rum "0.10.8" :exclusions [cljsjs/react cljsjs/react-dom]]
[cljsjs/react "15.5.0-0"]
[cljsjs/react-dom "15.5.0-0"]
[cljsjs/react-dom-server "15.5.0-0"]
```

But it does occur with the latest versions (e.g. Rum 0.11.2 and React 16.3.0-1).
