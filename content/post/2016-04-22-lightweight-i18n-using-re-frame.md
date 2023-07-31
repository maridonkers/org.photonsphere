+++
author = "Mari Donkers"
title = "Lightweight i18n using re-frame modified"
date = "2016-04-22"
description = "A lightweight i18n solution for use with re-frame. It's inspired by Tower, a Clojure/Script i18n & L10n library."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Clojure",
    "ClojureScript",
    "GUI",
]
categories = [
    "linux",
    "clojure",
]
series = ["Linux", "clojure"]
aliases = ["2016-04-22-lightweight-i18n-using-re-frame"]
thumbnail = "/images/clojure.svg"
+++

A lightweight [i18n](https://en.wikipedia.org/wiki/Internationalization_and_localization) solution for use with [re-frame](https://github.com/Day8/re-frame). It's inspired by [Tower, a Clojure/Script i18n & L10n library](https://github.com/ptaoussanis/tower).

Update: later found the [Tongue](https://github.com/tonsky/tongue) library (by **Nikita Prokopov**).
<!--more-->

# i18n code

``` clojure
(ns examplens.i18n
  (:require [examplens.translations :refer [translations]]))

(def i18n-not-found-key "*I18N-KEY*")
(def i18n-not-found-fallback-lc "*I18N-FB-LC*")

(defn- _t
 "Returns translation for key based on supplied locale."
 [lc key]
 {:pre [(not (nil? key))]
 :post [(not (nil? %))]}

 (let [fb-lc (:fallback-lc translations)
       td (:dictionary translations)
       tdk (get td key)]
   (if (nil? tdk)
      i18n-not-found-key
      (if (and (not (nil? lc)) (contains? tdk lc))
        (get tdk lc)
        (if (contains? tdk fb-lc)
          (get tdk fb-lc)
          i18n-not-found-fallback-lc)))))

(def t
  "Returns memoized translation for key (based on supplied locale)."
  (memoize _t))
```

# Example translations code

``` clojure
(ns examplens.translations)

(def translations
  "Table with translations per locale."
  {:fallback-lc :en-US
   :dictionary
   {:home-title {:en-US "Welcome"
                  :nl-NL "Welkom"}
    :home-subtitle {:en-US "Time to start building the site."
                     :nl-NL "Tijd om de site te maken."}
    :home-content {:en-US "The content for the home page."
                    :nl-NL "De inhoud voor de home pagina."}}})
```

# The re-frame related code

``` clojure
;; In the re-frame database a :lc field is
;; defined (with an initial value).
... {:lc :nl-NL} ...

;; Handler.
(f/register-handler
  :set-lc
  (fn [db [lc]]
    (assoc db :lc lc)))

;; A subscription handler is set up.
(f/register-sub
  :lc
  (fn [db _]
    (reaction (:lc @db))))

;; Consumption in a re-frame component (when the locale
;; changes the view is automatically updated).
(defn home []
  (let [lc (f/subscribe [:lc])]
    (fn []
       [:div
        [:div
         [:h1 (i18n/t @lc :home-title)]]
        [:div
         [:h3 (i18n/t @lc :home-subtitle)]]
        [:div
         [:p (i18n/t @lc :home-content)]]])))
```
