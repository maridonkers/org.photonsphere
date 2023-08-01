+++
author = "Mari Donkers"
title = "Om Next subcomponents using DataScript store"
date = "2016-01-16"
description = "Example of using Om Next subcomponents with a DataScript store."
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
aliases = ["2016-01-16-om-next-subcomponents-and-datascript"]
thumbnail = "/images/clojure.svg"
+++

# Introduction

Example of using [Om Next](https://github.com/omcljs/om/wiki/Quick-Start-(om.next)) subcomponents with a [DataScript](https://github.com/tonsky/datascript) store. This new attempt has better hierarchy, using secretary routing with one root component (App) responding to changes in the DataScript store. The database changes, which are done in the secretary routing functions via an Om Next mutate, are manually calling the parser function, thus avoiding direct knowledge of underlying storage mechanism (see routing.cljs in the listings below).
<!--more-->

This example code is on github: <https://github.com/maridonkers/om-next-datascript>

Updates:

- have also found this on GitHub: [Om TodoMVC Example](https://github.com/swannodette/om-next-demo) (by David Nolen);
- my routing solution is not as advised ([Routing Support](https://github.com/omcljs/om/wiki/Routing-Support)); another implementation using the suggested approach is here: [Routing with set-query!](./2016-01-29-om-next-routing-with-om-nextset-query.html);
- information on routing hooks soon to come: <https://github.com/omcljs/om/wiki/Routing-Hooks>.

# project.clj

``` clojure
(defproject browser "0.0.0-SNAPSHOT"
  :description "browser"
  :dependencies [[org.clojure/clojure "1.7.0"]
                 [org.clojure/clojurescript "1.7.228"]
                 [org.omcljs/om "1.0.0-alpha28"]
                 [datascript "0.15.0"]

                 [secretary "1.2.3"]

                 [com.cemerick/piggieback "0.2.1"]
                 [figwheel-sidecar "0.5.0-3" :scope "test"]])
```

# script/figwheel.clj

``` clojure
(require '[figwheel-sidecar.repl :as r]
         '[figwheel-sidecar.repl-api :as ra])

;; In Emacs use M-x cider-jack-in to start REPL and then C-c C-k) to
;; load this file and start figwheel.
;;
;; (Beware: piggieback must have been added to Leiningen dependencies, e.g.
;; as follows: [com.cemerick/piggieback "0.2.1"])
;;
;; See documentation at:
;; https://github.com/bhauman/lein-figwheel/wiki/Using-the-Figwheel-REPL-within-NRepl
;;
(ra/start-figwheel!
 {:figwheel-options {}
  :build-ids ["dev"]
  :all-builds
  [{:id "dev"
    :figwheel true
    :source-paths ["src"]
    :compiler {:main 'browser.core
               :asset-path "js"
               :output-to "resources/public/js/main.js"
               :output-dir "resources/public/js"
               :verbose true}}]})

(ra/cljs-repl)
```

# src/browser/ds.cljs

``` clojure
(ns browser.ds
  (:require [datascript.core :as d]))

;; Database schema (only type ref entities need be specified).
(def schema {:app/dimensions {:db/valueType :db.type/ref}})

;; Database connection.
(def conn (d/create-conn schema))

;; Log database transactions for debug purposes. BEWARE: nil as a value
;; is not allowed and should not show up in logs!
(d/listen! conn :log
           (fn [tx-report]
             (println (str "DS: " (:tx-data tx-report)))))

;; Initial contents of (in-memory) database.
(defn init!
  "Initializes database contents."
  []
  {:post [(not (nil?  %))]}
  (d/transact! conn
               [{:db/id -1
                 :navbar/key :navbar
                 :navbar/collapsed? true}

                {:db/id -2
                 :home/key :home
                 :home/title "HOME (to be done)"
                 :home/count 0}

                {:db/id -3
                 :about/key :about
                 :about/title "ABOUT (to be done)"}

                {:db/id -4
                 :about/key :error
                 :about/title "ERROR (to be done)"}

                {:db/id -100
                 :app/key :app
                 :app/page "/"
                 :app/locale :nl-NL
                 :app/logged-in? true
                 :app/dimensions {:db/id -1000
                                  :dimensions/orientation :landscape
                                  :dimensions/width 1024
                                  :dimensions/height 768}}]))

;;---------------------
;; Initialize database.
(init!)
```

# src/browser/core.cljs

``` clojure
(ns browser.core
  (:require [browser.util :as util]
            [browser.routing :as routing]))

(enable-console-print!)

;; -------------------------
;; Set-up.
(routing/hook-browser-navigation!)
(routing/om-next-root!)
(routing/restore-page!)
```

# src/browser/util.cljs

``` clojure
(ns browser.util)

(defn nav!
  "Navigates to supplied page by updating the URL."
  [url]
  (set! (.. js/document -location -href) (str "#" url)))
```

# src/browser/reconciler.cljs

``` clojure
(ns browser.reconciler
  (:require [om.next :as om]

            [browser.ds :as ds]))

;; -------------------------
;; The Om Next read functions
(defmulti read
  "Read data from DataScript store."
  om/dispatch)

;; -----------------------------
;; The Om Next mutate functions.
(defmulti mutate
  "Mutate data in DataScript store."
  om/dispatch)

;; -------------------
;; The Om Next parser.
;;
(def parser (om/parser {:read read :mutate mutate}))

;; -------------------------
;; Configures Om Next read and mutate functions.
(def reconciler
  (om/reconciler
   {:state ds/conn
    :parser parser}))
```

# src/browser/routing.cljs

``` clojure
(ns browser.routing
  (:require [goog.dom :as gdom]
            [om.next :as om]
            [datascript.core :as d]

            [secretary.core :as secretary :include-macros true]
            [goog.events :as events]
            [goog.history.EventType :as EventType]

            [browser.ds :as ds]
            [browser.util :as util]
            [browser.reconciler :refer [reconciler parser]]

            [browser.app :refer [App]])
  (:import goog.History))

;;-------------
;; Change page.
;;
;; Use Om Next parser to avoid direct knowledge of underlying storage.
;;
(defn set-page!
  "Sets page in Om Next data."
  [new-page]

  (let [app-props (parser {:state ds/conn}
                          [{:app/query [:db/id :app/page]}])
        entity (get-in app-props [:app/query 0])
        {:keys [db/id
                app/page]} entity]

    (when (not= page new-page)
      (parser {:state ds/conn}
              `[(app/set-page ~{:db/id id :app/page new-page})]))))

;; -------
;; Routes.
;; Extend when pages added. Also see case-statement
;; in browser.app component.
;;
(secretary/set-config! :prefix "#")

(secretary/defroute home-page "/" []
  (set-page! "/")) 

(secretary/defroute about-page "/about" []
  (set-page! "/about"))

;; --------
;; History.
;; must be called after routes have been defined.
(defn hook-browser-navigation!
  "Connects browser navigation to secretary routing."
  []
  (doto (History.)
    (events/listen
     EventType/NAVIGATE
     (fn [event]
       (secretary/dispatch! (.-token event))))
    (.setEnabled true)))

(defn om-next-root!
  "Sets Om Next root component."
  []
  (om/add-root! reconciler
                App (gdom/getElement "app")))

(defn restore-page!
  "Restores saved page (if any); otherwise home page."
  []

  (if-let [url (d/q '[:find ?p .
                      :where [?e :app/page ?p]] @ds/conn)]
    (util/nav! url)))
```

# src/browser/app.cljs

``` clojure
(ns browser.app
  (:require [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]
            [secretary.core :as secretary]

            [browser.parsers.app :as app-parser]

            [browser.navbar :refer [Navbar navbar]]
            [browser.pages.home :refer [HomePage home-page]]
            [browser.pages.about :refer [AboutPage about-page]]
            [browser.pages.error :refer [ErrorPage error-page]]))

;;------------------
;; Om Next component
;;
;; This defines dimensions.
(defui Dimensions
  static om/IQuery
  (query [this]
         [:db/id
          :dimensions/orientation
          :dimensions/width
          :dimensions/height]))

;;------------------------
;; Om Next root component.
;;
(defui App
  static om/IQuery
  (query [this]
         [{:app/query [:db/id
                       :app/page
                       :app/locale
                       :app/logged-in?
                       {:app/dimensions (om/get-query Dimensions)}]}

          {:navbar/query (om/get-query Navbar)}
          {:home/query (om/get-query HomePage)}
          {:about/query (om/get-query AboutPage)}
          {:error/query (om/get-query ErrorPage)}])

  Object
  (render [this]
          (let [props (om/props this)

                app-props (get-in (om/props this) [:app/query 0])
                navbar-props (get-in (om/props this) [:navbar/query 0])
                home-props (get-in (om/props this) [:home/query 0])
                about-props (get-in (om/props this) [:about/query 0])
                error-props (get-in (om/props this) [:error/query 0])

                {:keys [db/id
                        app/page
                        app/locale
                        app/logged-in?]} app-props]

            (dom/div nil
                     (navbar (om/computed navbar-props
                                          {:app-id id
                                           :lc locale
                                           :logged-in? logged-in?}))

                     ;; Extend this when new pages are added. Also see routes
                     ;; in browser.routing component.
                     ;;
                     (case page
                       "/" (home-page home-props)
                       "/about" (about-page about-props)
                       (error-page error-props))))))
```

# src/browser/navbar.cljs

``` clojure
(ns browser.navbar
  (:require [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]

            [browser.util :as util]

            [browser.parsers.navbar :as navbar-parser]))

;;-------------------
;; Om Next component.
(defui Navbar
  static om/IQuery
  (query [this]
         [:db/id
          :navbar/collapsed?])
  Object
  (render
   [this]
   (dom/div
    nil
    (let [props (om/props this)

          {:keys [navbar/collapsed?]} props

          cmp (om/get-computed props)
          {:keys [app-id
                  lc
                  logged-in?]} cmp]

      (when logged-in?
        (dom/button
         #js {:type "button"
              :onClick (fn [e]
                         (util/nav! "/")
                         (let [entity {:db/id app-id}]
                   (om/transact! this
                                 `[(app/logout ~entity)])))}
         "Logout!"))))))

(def navbar (om/factory Navbar))
```

# src/browser/pages/home.cljs

``` clojure
(ns browser.pages.home
  (:require [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]
            [datascript.core :as d]

            [browser.util :as util]

            [browser.parsers.home :as home-parser]))

;; ------------------------------------
;; Om Next component for the home page.
(defui HomePage
  static om/IQuery
  (query [this]
         [:db/id :home/title :home/count])
  Object
  (render [this]
          (let [props (om/props this)

                {:keys [db/id
                        home/title
                        home/count]} props]

            (dom/div
             nil
             (dom/h2 nil title)
             (dom/span nil (str "Home (count): " count))
             (dom/button
              #js {:type "button"
                   :onClick (fn [e]
                              (util/nav! "/about")
                              (let [entity {:db/id id :home/count count}]
                                (om/transact! this
                                              `[(home/increment ~entity)])))}
              "Increment!")))))

(def home-page (om/factory HomePage))
```

# src/browser/pages/about.cljs

``` clojure
(ns browser.pages.about
  (:require [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]
            [datascript.core :as d]

            [browser.util :as util]

            [browser.parsers.about :as about-parser]))

;; ------------------------------------
;; Om Next component for the about page.
(defui AboutPage
  static om/IQuery
  (query [this]
         [:db/id :about/title])
  Object
  (render [this]
          (let [props (om/props this)

                {:keys [about/title]} props]

            (dom/div
             nil
             (dom/h2 nil title)
             (dom/button
              #js {:type "button"
                   :onClick (fn [e]
                              (util/nav! "/"))}
              "HOME!")))))

(def about-page (om/factory AboutPage))
```

# src/browser/pages/error.cljs

``` clojure
(ns browser.pages.error
  (:require [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]
            [datascript.core :as d]

            [browser.util :as util]

            [browser.parsers.error :as error-parser]))

;; -------------------------------------
;; Om Next component for the error page.
(defui ErrorPage
  static om/IQuery
  (query [this]
         [:db/id :error/title])
  Object
  (render [this]
          (let [props (om/props this)

                {:keys [error/title]} props]

            (dom/div
             nil
             (dom/h2 nil title)
             (dom/button
              #js {:type "button"
                   :onClick (fn [e]
                              (util/nav! "/"))}
              "HOME!")))))

(def error-page (om/factory ErrorPage))
```

# src/browser/parsers/app.cljs

``` clojure
(ns browser.parsers.app
  (:require [om.next :as om]
            [datascript.core :as d]

            [browser.reconciler :refer [mutate read]]))

(defmethod read :app/query
  [{:keys [state query]} _ _]

  {:value (d/q '[:find [(pull ?e ?selector) ...]
                 :in $ ?selector
                 :where [?e :app/key]]
               (d/db state) query)})

(defmethod mutate 'app/set-page
  [{:keys [state]} _ entity]

  {:value {:keys [:app/query]}
   :action (fn []
             (d/transact! state
                          [entity]))}) ;; new value in entity

(defmethod mutate 'app/login
  [{:keys [state]} _ entity]

  {:value {:keys [:app/query]}
   :action (fn []
             (d/transact! state
                          [(assoc entity :app/logged-in? true)]))})

(defmethod mutate 'app/logout
  [{:keys [state]} _ entity]

  {:value {:keys [:app/query]}
   :action (fn []
             (d/transact! state
                          [(assoc entity :app/logged-in? false)]))})
```

# src/browser/parsers/navbar.cljs

``` clojure
(ns browser.parsers.navbar
  (:require [om.next :as om]
            [datascript.core :as d]

            [browser.reconciler :refer [mutate read]]))

(defmethod read :navbar/query
  [{:keys [state query]} _ _]

  {:value (d/q '[:find [(pull ?e ?selector) ...]
                 :in $ ?selector
                 :where [?e :navbar/key]]
               (d/db state) query)})
```

# src/browser/parsers/home.cljs

``` clojure
(ns browser.parsers.home
  (:require [om.next :as om]
            [datascript.core :as d]

            [browser.reconciler :refer [mutate read]]))

;;-----------------------
;; Parser read functions.
(defmethod read :home/query
  [{:keys [state query]} _ _]

  {:value (d/q '[:find [(pull ?e ?selector) ...]
                 :in $ ?selector
                 :where [?e :home/key]]
               (d/db state) query)})

;;-------------------------
;; Parser mutate functions.
(defmethod mutate 'home/increment
  [{:keys [state]} _ entity]

  {:value {:keys [:home/query]}
   :action (fn []
             (d/transact! state
                          [(update-in entity [:home/count] inc)]))})
```

# src/browser/parsers/about.cljs

``` clojure
(ns browser.parsers.about
  (:require [om.next :as om]
            [datascript.core :as d]

            [browser.reconciler :refer [mutate read]]))

;;-----------------------
;; Parser read functions.
(defmethod read :about/query
  [{:keys [state query]} _ _]

  {:value (d/q '[:find [(pull ?e ?selector) ...]
                 :in $ ?selector
                 :where [?e :about/key]]
               (d/db state) query)})

;;-------------------------
;; Parser mutate functions.
```

# src/browser/parsers/error.cljs

``` clojure
(ns browser.parsers.error
  (:require [om.next :as om]
            [datascript.core :as d]

            [browser.reconciler :refer [mutate read]]))

;;-----------------------
;; Parser read functions.
(defmethod read :error/query
  [{:keys [state query]} _ _]

  {:value (d/q '[:find [(pull ?e ?selector) ...]
                 :in $ ?selector
                 :where [?e :error/key]]
               (d/db state) query)})

;;-------------------------
;; Parser mutate functions.
```

# src/browser/resources/public/index.html

``` html
<html>
  <head lang="en">
    <META http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Welcome</title>
  </head>
  <body>
    <div id="app"></div>
    <script src="js/main.js"></script>
  </body>
</html>
```
