+++
author = "Mari Donkers"
title = "Adding Crux to a Fulcro template"
date = "2019-06-01"
description = "Adding Crux database to a Fulcro template project. To set up Emacs for Clojure and ClojureScript development with Cider."
featured = false
tags = [
    "Computer",
    "Software",
    "Internet",
    "Server",
    "Client",
    "Database",
    "GUI",
    "Functional Programming",
    "Clojure",
    "ClojureScript",
    "Full Stack",
    "Editor",
    "Emacs",
    "IDE",
]
categories = [
    "clojure",
    "full stack"
]
series = ["Clojure", "Full Stack"]
aliases = ["2019-06-01-crux-with-fulcro-template"]
thumbnail = "/images/clojure.svg"
+++

Adding [Crux](https://juxt.pro/crux/index.html) database to a [Fulcro](http://fulcro.fulcrologic.com/) template project. To set up Emacs for [Clojure](http://clojure.org/) and [ClojureScript](http://clojurescript.org/) development with Cider see e.g.: [My Emacs configuration](./2017-04-13-emacs-config.html)
<!--more-->

# New Fulco project from template

``` bash
lein new fulcro yourprojectname
```

Your Fulcro project is now in the subdirectory `yourprojectname`.

# Initialize development environment (once)

``` bash
npm install  # only need to do this once
```

# Add Crux to deps.edn

In file `deps.edn` add `juxt/crux` to existing dependencies and emacs stuff:

``` clojure
{:paths ["src/main" "resources"]

 :deps {bidi {:mvn/version "2.1.5"}
        bk/ring-gzip {:mvn/version "0.3.0"}
        com.taoensso/timbre {:mvn/version "4.10.0"}
        com.wsscode/pathom {:mvn/version "2.2.12"}
        fulcrologic/fulcro {:mvn/version "2.8.8"}
        fulcrologic/fulcro-incubator {:mvn/version "0.0.32"}
        garden {:mvn/version "1.3.6"}
        hiccup {:mvn/version "1.0.5"}
        juxt/crux {:mvn/version "19.04-1.0.3-alpha"}
        http-kit {:mvn/version "2.3.0"}
        ; clj-time {:mvn/version "0.15.1"}
        mount {:mvn/version "0.1.14"}
        org.clojure/clojure {:mvn/version "1.10.1-beta2"}
        org.clojure/core.async {:mvn/version "0.4.490"}
        ring/ring-core {:mvn/version "1.7.1"}
        ring/ring-defaults {:mvn/version "0.3.2"}}

 :aliases {:clj-tests {:extra-paths ["src/test"]
                       :main-opts   ["-m" "kaocha.runner"]
                       :extra-deps  {lambdaisland/kaocha {:mvn/version "0.0-389"}}}

           ;; See https://github.com/clojure-emacs/cider-nrepl/blob/master/deps.edn for Emacs support
           :dev       {:extra-paths ["src/test" "src/dev" "src/workspaces"]
                       :jvm-opts    ["-XX:-OmitStackTraceInFastThrow"]
                       :extra-deps  {org.clojure/clojurescript {:mvn/version "1.10.520"}
                                     fulcrologic/fulcro-spec {:mvn/version "3.0.0"}
                                     thheller/shadow-cljs {:mvn/version "2.8.25"}
                                     binaryage/devtools {:mvn/version "0.9.10"}
                                     nubank/workspaces {:mvn/version "1.0.3"},
                                     fulcrologic/fulcro-inspect {:mvn/version "2.2.4"}
                                     org.clojure/tools.namespace {:mvn/version "0.3.0-alpha4"}
                                     org.clojure/tools.nrepl {:mvn/version "0.2.13"}
                                     cider/cider-nrepl {:mvn/version "0.21.0"}}}
           :cider-clj {:extra-deps {org.clojure/clojure {:mvn/version "1.9.0"}}
                       :main-opts ["-m" "nrepl.cmdline" "--middleware" "[cider.nrepl/cider-middleware]"]}

           :cider-cljs {:extra-deps {org.clojure/clojure {:mvn/version "1.9.0"}
                                     org.clojure/clojurescript {:mvn/version "1.10.339"}
                                     cider/piggieback {:mvn/version "0.3.9"}}
                        :main-opts ["-m" "nrepl.cmdline" "--middleware"
                                    "[cider.nrepl/cider-middleware,cider.piggieback/wrap-cljs-repl]"]}}}    
```

# Add Crux configuration to defaults.edn

To file `src/main/config/defaults.edn` add the following section:

``` clojure
;;TODO Check validity of these parameters; they don't work in production uberjar!
;; See: https://juxt.pro/crux/docs/configuration.html
 :crux.api/config {:kv-backend "crux.kv.memdb.MemKv"
                   :db-dir "data/db-dir-1"}
```

# Add file db_server.clj

Add file `src/main/yourprojectname/server_components/db_server.clj` with following contents:

``` clojure
(ns yourprojectname.server-components.db-server
  (:require
   [yourprojectname.server-components.config :refer [config]]
   [mount.core :refer [defstate]]
   [clojure.pprint :refer [pprint]]
   [taoensso.timbre :as log]
   [crux.api :as crux]))

(defstate db-server
  :start (let [cfg (::crux/config config)]
           (log/info "Starting Database Server with config " (with-out-str (pprint cfg)))
           (crux/start-standalone-system cfg))
  :stop (.close db-server))
```

# Change file http_server.clj

Change require in file `src/main/yourprojectname/server_components/http_server.clj` to include `yourprojectname.server-components.db-server` namespace:

``` clojure
(:require
    [yourprojectname.server-components.config :refer [config]]
    [yourprojectname.server-components.middleware :refer [middleware]]
    [yourprojectname.server-components.db-server]
    [mount.core :refer [defstate]]
    [clojure.pprint :refer [pprint]]
    [org.httpkit.server :as http-kit]
    [taoensso.timbre :as log])
```

# Replace user.clj file

Replace file `src/main/yourprojectname/model/user.clj` with following contents:

``` clojure
(ns yourprojectname.model.user
  (:require
   [com.wsscode.pathom.connect :as pc]
   [yourprojectname.server-components.pathom-wrappers :refer [defmutation defresolver]]
   [yourprojectname.server-components.db-server :refer [db-server]]
   [taoensso.timbre :as log]
   #_[clj-time.core :as time]
   #_[clj-time.format :as ftime]
   [crux.api :as crux]))

#_(def built-in-formatter (ftime/formatters :date-time))

(defn dump-db []
  (let [q (crux/q (crux/db db-server)
                  '{:find [i]
                    :where [[i :crux.db/id _]]})]
    (map (fn [e] (crux/entity (crux/db db-server) (first e))) q)))

#_(def user-database (atom {}))
;; Example contents dump.
;; @user-database
#_{"e996f209-0810-4b29-ab5d-530582769ccd"
 #:user{:id "e996f209-0810-4b29-ab5d-530582769ccd",
        :name "User e996f209-0810-4b29-ab5d-530582769ccd"},
 "3622054c-6dd9-4d60-a686-581dd95b51eb"
 #:user{:id "3622054c-6dd9-4d60-a686-581dd95b51eb",
        :name "User 3622054c-6dd9-4d60-a686-581dd95b51eb"},
 "9d75d157-ec7e-4b0b-8c70-d615cb3152a8"
 #:user{:id "9d75d157-ec7e-4b0b-8c70-d615cb3152a8",
        :name "User 9d75d157-ec7e-4b0b-8c70-d615cb3152a8"},
 "c008fa6a-c348-4386-82c1-f04d04dcf65f"
 #:user{:id "c008fa6a-c348-4386-82c1-f04d04dcf65f",
        :name "User c008fa6a-c348-4386-82c1-f04d04dcf65f"}}

(defresolver all-users-resolver
  "Resolve queries for :all-users."
  [env input]
  {;;GIVEN nothing
   ::pc/output [{:all-users [:user/id]}]}

  ;; I can output all users. NOTE: only ID is needed...other resolvers resolve the rest.
  #_(log/info "All users. Database contains: " @user-database)
  (let [q (crux/q (crux/db db-server)
                  '{:find [d]
                    :where [[_ :user/id d]]})]
    {:all-users (mapv (fn [id] {:user/id (first id)})
                      #_(keys @user-database)
                      q)}))

(defresolver user-resolver
  "Resolve details of a single user.  (See pathom docs for adding batching)"
  [env {:user/keys [id]}]
  {::pc/input  #{:user/id}                                  ; GIVEN a user ID
   ::pc/output [:user/name]}                                ; I can produce a user's details

  ;; Look up the user (e.g. in a database), and return what you promised.
  #_(when (contains? @user-database id)
    (get @user-database id))
  (let [kid (keyword id)
        q (crux/entity (crux/db db-server) kid)]
    (into {} (filter (fn [e] (= (namespace (key e)) "user")) q))))

(defresolver user-address-resolver
  "Resolve address details for a user. Note the address data could be stored on the user in the database or elsewhere."
  [env {:user/keys [id]}]
  {::pc/input  #{:user/id}                                  ; GIVEN a user ID
   ::pc/output [:address/id :address/street :address/city :address/state :address/postal-code]}

  ;;TODO Address with user in database (get it here).
  ;; I can produce address details
  (log/info "Resolving address for " id)
  #_{:address/id          "fake-id"
   :address/street      "111 Main St."
   :address/city        "Nowhere"
   :address/state       "WI"
   :address/postal-code "99999"}

  (let [kid (keyword id)
        q (crux/entity (crux/db db-server) kid)]
    (into {} (filter (fn [e] (= (namespace (key e)) "address")) q))))

(defmutation upsert-user
  "Add/save a user. Required parameters are:

  :user/id - The ID of the user
  :user/name - The name of the user

  Returns a User (e.g. :user/id) which can resolve to a mutation join return graph.
  "
  [{:keys [config ring/request]} {:user/keys [id name]}]
  {::pc/params #{:user/id :user/name}
   ::pc/output [:user/id]}

  (log/debug "Upsert user with server config that has keys: " (keys config))
  (log/debug "Ring request that has keys: " (keys request))
  (log/debug "UPSERT-USER: " id " " name)
  (when (and id name)
    ;;TODO Add user to database; example given below:
    (let [kid (keyword id)]
      (crux/submit-tx db-server
                      [[:crux.tx/put kid ; id for Kafka
                        {:crux.db/id kid ; id for Crux
                         :user/id id
                         :user/name name
                         :address/id "fake-id"
                         :address/street (str (int (rand 1000)) " Main Street")
                         :address/city (nth ["New York" "Los Angeles"
                                             "Chicago" "Houston"
                                             "Phoenix" "Philadelphia"
                                             "San Antonio" "San Diego"
                                             "Dallas" "San Jose"] (int (rand 10)))
                         :address/state "WI"
                         :address/postal-code "99999"}]]))
    #_(swap! user-database assoc id {:user/id id
                                     :user/name name})
    ;; Returning the user id allows the UI to query for the result. In
    ;; this case we're "virtually" adding an address for them!
    {:user/id id}))
```

# Start headless REPL

Start a headless REPL.

``` bash
npx shadow-cljs server
```

Jot down the port on which the nREPL server started.

# Connect to REPL (for Clojure)

In Emacs use `M-x cider-connect` to connect to the REPL. Normally you can use the default (localhost) and also press ENTER for the port number (which automatically finds the port number). If it doesn't work then use the jotted down port number.

# Start the server in the Clojure REPL

``` clojure
(start)
```

The page can be found at: [<http://localhost:3000>](http://localhost:3000/).

# ClojureScript build

Navigate to <http://localhost:9630> and enable `main` build; wait until it completes; reload page at <http://localhost:3000/>.

# Create a second connection to the REPL (for ClojureScript)

Under Emacs use `CIDER` -\> `ClojureScript` -\> `Connect to a
Clojurescript REPL` with defaults for hosts and port; answer yes to =A session with the same parameters exists (…). You can connect a sibling instead. Proceed?=; choose `shadow-select` as the REPL type and `main` for build.

## Initial app state

To view initial app state (e.g. in ClojureScript REPL) use the following (optionally with `cljs.pprint/print` to get a nicely formatted version):

``` clojure
(fulcro.client.primitives/get-initial-state yourprojectname.ui.root/Root {})
```

## Current app state

To view current app state (e.g. in ClojureScript REPL) use the following (optionally with `cljs.pprint/print` to get a nicely formatted version):

``` clojure
@(fulcro.client.primitives/app-state (get @yourprojectname.client/SPA :reconciler))
```

# Screendump (example)

After playing around with the demo project and adding some users, one gets e.g.:

![](/images/crux-fulcro-template.png)

# Database dump (example)

From your Clojure REPL prompt, do a dump-db to get the database contents matching the above screendump example.

``` clojure
user> (yourprojectname.model.user/dump-db)
({:crux.db/id :5dd9c16d-42bb-46bf-a5b7-be4728d7cd92,
  :user/id "5dd9c16d-42bb-46bf-a5b7-be4728d7cd92",
  :user/name "User 5dd9c16d-42bb-46bf-a5b7-be4728d7cd92",
  :address/id "fake-id",
  :address/street "846 Main Street",
  :address/city "Phoenix",
  :address/state "WI",
  :address/postal-code "99999"}
 {:crux.db/id :8614d58e-ad02-4dd4-8c17-740f981d38de,
  :user/id "8614d58e-ad02-4dd4-8c17-740f981d38de",
  :user/name "User 8614d58e-ad02-4dd4-8c17-740f981d38de",
  :address/id "fake-id",
  :address/street "403 Main Street",
  :address/city "San Diego",
  :address/state "WI",
  :address/postal-code "99999"}
 {:crux.db/id :389ae1ee-0197-4236-a79c-df906a64fbbe,
  :user/id "389ae1ee-0197-4236-a79c-df906a64fbbe",
  :user/name "User 389ae1ee-0197-4236-a79c-df906a64fbbe",
  :address/id "fake-id",
  :address/street "822 Main Street",
  :address/city "Los Angeles",
  :address/state "WI",
  :address/postal-code "99999"}
 {:crux.db/id :b7a3146b-8ac0-4b7b-94b6-f3a2c400dbfa,
  :user/id "b7a3146b-8ac0-4b7b-94b6-f3a2c400dbfa",
  :user/name "User b7a3146b-8ac0-4b7b-94b6-f3a2c400dbfa",
  :address/id "fake-id",
  :address/street "654 Main Street",
  :address/city "Dallas",
  :address/state "WI",
  :address/postal-code "99999"}
 {:crux.db/id :2f72197e-8829-47c3-9d52-dd54bac5ed1c,
  :user/id "2f72197e-8829-47c3-9d52-dd54bac5ed1c",
  :user/name "User 2f72197e-8829-47c3-9d52-dd54bac5ed1c",
  :address/id "fake-id",
  :address/street "652 Main Street",
  :address/city "Philadelphia",
  :address/state "WI",
  :address/postal-code "99999"})
```
