+++
author = "Mari Donkers"
title = "Om Next routing with om.next/set-query!"
date = "2016-01-29"
description = "An implementation of client side routing using the client-side router library secretary and om.next/set-query."
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
    "clojure",
]
series = ["Clojure"]
aliases = ["2016-01-29-om-next-routing-with-om-nextset-query"]
thumbnail = "/images/clojure.svg"
+++

—- title: Om Next routing with om.next/set-query! modified: 2016-01-29 meta<sub>description</sub>: tags: Computer, Software, GUI, Functional, Clojure, ClojureScript —-

An implementation of client side routing using the client-side router library [secretary](https://github.com/gf3/secretary) and [om.next/set-query!](https://github.com/omcljs/om/wiki/Documentation-(om.next)#set-query). Note: this solution may become outdated when [Routing-Hooks](https://github.com/omcljs/om/wiki/Routing-Hooks) is made available. Further reading on Om Next routing, see: [Routing-Support](https://github.com/omcljs/om/wiki/Routing-Support).

Also **take a look first at:** [Routing in Om Next — a Catalog of Approaches](http://anmonteiro.com/2016/02/routing-in-om-next-a-catalog-of-approaches/), which describes Om Next routing variants without third party client-side router libraries. (In fact this catalog of approaches obsoletes my article so you might as well stop reading and go the the above link directly.)
<!--more-->

# GitHub

The code for this example is on [GitHub](https://github.com/maridonkers/om-next-routing).

# Implementation

(excuse my Clojure –rookie)

``` clojure
(ns yourproject.app
  (:require [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]
            [secretary.core :as secretary]

            [clojure.string :as s]
            [yourproject.util :as util]

            [yourproject.reconciler :refer [reconciler]]
            [yourproject.parsers.app :as app-parser]

            [yourproject.navbar :refer [Navbar navbar]]
            [yourproject.pages.home :refer [HomePage home-page]]
            [yourproject.pages.browse :refer [BrowsePage browse-page]]
            [yourproject.pages.about :refer [AboutPage about-page]]))

;;-----------
;; Constants.
(def pages
  "Information on pages. Update this when new pages are added. Also
  update the routes in the routing namespace. Beware: (a) keywords
  *must* start with the :page+ prefix. (b) the URL /home is an alias
  for / (under the hood) so don't define a /home entry."

  {"/" [:page+home
        (om/get-query HomePage)
        home-page]
   "/browse" [:page+browse
              (om/get-query BrowsePage)
              browse-page]
   "/about" [:page+about
             (om/get-query AboutPage)
             about-page]})

;;---------
;; Queries.
(def app-query
  "Application level query."
  {:app [:logged-in?]})

(def navbar-query
  "Navbar query"
  {:navbar (om/get-query Navbar)})

(defn page-query
  "Gets query by page keyword and page subquery."
  [kw sq]
  {kw sq})

(defn query-by-page
  "Gets query by page."
  [page]
  {:pre [(not (nil? page))]
   :post [(not (nil? %))]}

  (if (contains? pages page)
    (let [pi (get pages page)]
      [app-query
       navbar-query
       (page-query (first pi) (second pi))])
    ;; Forces post-assert fail.
    nil))

(defn page-info-by-props
  "Gets pages element for query via props."
  [props]
  {:pre [(not (nil? props))]
   :post [(not (nil? %))]}

  (let [kw (first (filter #(s/starts-with? (str %) ":page+")
                          (keys props)))]
    (if (not (nil? kw))
      ;; Here kw has a :page+ type keyword.
      (let [kws (str kw)
            pg (str "/" (subs kws 6))
            pgi (if (= pg "/home") "/" pg)]
        (get pages pgi))
      ;; Forces post-assert fail.
      nil)))

(defn keyword-by-props
  "Gets keyword for query via props."
  [props]
  {:pre [(not (nil? props))]
   :post [(not (nil? %))]}

  (let [pi (page-info-by-props props)]
    (if (not (nil? pi))
      (first pi)
      ;; Forces post-assert fail.
      nil)))

(defn factory-fcn-by-props
  "Gets factory function for query via props."
  [props]
  {:pre [(not (nil? props))]
   :post [(not (nil? %))]}

  (let [pi (page-info-by-props props)]
    (if (not (nil? pi))
      (second (next pi))
      ;; forces post-assert fail
      nil)))

;;------------------------
;; Om-next root component.
;;
(defui App
  static om/IQuery
  (query [this]
         (query-by-page "/"))

  Object
  (render [this]

          (let [props (om/props this)
                app-props (:app props)
                {:keys [logged-in?]} app-props

                navbar-props (:navbar props)
                pkw (keyword-by-props props)
                page-props (pkw props)]

            (dom/div nil
                     (dom/h4 nil (str "*** "(if logged-in? "LOGGED IN" "LOGGED OUT") "***"))

                     (navbar navbar-props)
                     ((factory-fcn-by-props props) page-props)))))

;;-----------------
;; Sets page.
;;
(defn set-page!
  "Sets page via an Om Next set-query call. The resulting re-render of
  App displays the new page."
  [page]
  {:pre [(not (nil? page))]}

  (let [root (om/app-root reconciler)]
    (when (and (not (nil? page))
               (not (nil? root)))
      (let [q (query-by-page page)]
        (om/set-query! root
                       {:query q})))))
```
