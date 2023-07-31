+++
author = "Mari Donkers"
title = "Lightweight i18n using DataScript"
date = "2016-01-14"
description = "A lightweight ;-) i18n solution for ClojureScript that uses a DataScript database. It's inspired by Tower, a Clojure/Script i18n & L10n library."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Clojure",
    "ClojureScript",
    "Database",
]
categories = [
    "linux",
    "clojure",
]
series = ["Linux", "Clojure"]
aliases = ["2016-01-14-lightweight-i18n-using-datascript"]
thumbnail = "/images/clojure.svg"
+++

A lightweight ;-) i18n solution for [ClojureScript](https://github.com/clojure/clojurescript) that uses a [DataScript](https://github.com/tonsky/datascript) database. It's inspired by [Tower, a Clojure/Script i18n & L10n library](https://github.com/ptaoussanis/tower).

Update: later found the [Tongue](https://github.com/tonsky/tongue) library (by **Nikita Prokopov**).
<!--more-->

# Database example code

``` clojure
(ns yournamespace.dst
  (:require [datascript.core :as d]))

;; Database schema (only type ref entities need be specified).
(def schema {:i18n/dictionary {:db/valueType :db.type/ref}
             :dictionary/en-US {:db/valueType :db.type/ref}
             :dictionary/nl-NL {:db/valueType :db.type/ref}})

;; Database connection.
(def conn (d/create-conn schema))

;; Log database transactions for debug purposes. BEWARE: nil as a value
;; is not allowed and should not show up in logs!
#_(d/listen! conn :log
           (fn [tx-report]
             (println (str "DST: " (:tx-data tx-report)))))

;; Initial contents of (in-memory) database.
(defn init!
  "Initializes database contents."
  []
  {:post [(not (nil?  %))]}

  (d/transact! conn
               [{:db/id -1
                 :i18n/key :i18n
                 :i18n/fallback-locale :dictionary/en-US
                 :i18n/dictionary
                 {:db/id -10
                  :dictionary/en-US {:db/id -100
                          :main-title "Title"
                          :main-subtitle "Subtitle"
                  :dictionary/nl-NL {:db/id -101
                          :main-title "Titel"
                          :main-subtitle "Subtitel"
                          }}}]))

;;---------------------
;; Initialize database.
(init!)
```

# The i18n code

``` clojure
(ns yournamespace.i18n
  (:require [datascript.core :as d]
            [yournamespace.dst :as dst]))

(defn ^:private _get-lc
  "Gets locale if it exists, otherwise fallback locale"
  [lc]
  {:pre  [(not (nil? lc))]
   :post [(not (nil?  %))]}

  (let [lc-is-present?(not
                       (nil?
                        (d/q '[:find ?lc .
                               :in $ ?lci
                               :where [?e :i18n/key] [?e :i18n/dictionary ?d]
                               [?d ?lci ?lc]]
                             @dst/conn lc)))]
    (if lc-is-present?
      lc
      (d/q '[:find ?fl .
             :in $
             :where [?e :i18n/key] [?e :i18n/fallback-locale ?fl]]
           @dst/conn))))

(def ^:private get-lc (memoize _get-lc))

(defn ^:private _t
  "Returns translation for key based on supplied locale (lc)"
  [lc key]
  {:pre  [(not (nil? lc)), (not (nil? key))]
   :post [(not (nil?  %))]}

  (let [active-lc (get-lc lc)]
    (if (nil? active-lc)
      "***i18n - locale error***"
      (d/q '[:find ?txt .
             :in $ ?lc ?key
             :where [?e :i18n/key] [?e :i18n/dictionary ?dic]
             [?dic ?lc ?dl]
             [?dl ?key ?txt]]
           @dst/conn active-lc key))))

(def t (memoize _t))
```

# Caller code example

``` clojure
(ns yournamespace.caller
  (:require [yournamespace.i18n :as i18n]))

(let [lc :dictionary/nl-NL]
  (println (str "Title: " (i18n/t lc :main-title)))
  (println (str "Subtitle: " (i18n/t lc :main-subtitle))))
```
