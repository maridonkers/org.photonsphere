+++
author = "Mari Donkers"
title = "Date in URL Image scraper"
date = "2021-11-22"
description = "A Haskell program that uses the Conduit library to retrieve and store image files with Network.HTTP.Conduit, which are accessible via an URL with a date in it."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "Internet",
    "HTML",
]
categories = [
    "haskell",
]
series = ["Haskell"]
aliases = ["2021-11-22-haskell-conduit-http"]
thumbnail = "/images/haskell.svg"
+++

A [Haskell](https://haskell.org) program that uses the [Conduit](https://github.com/snoyberg/conduit) library to retrieve and store image files with [Network.HTTP.Conduit](https://hackage.haskell.org/package/http-conduit-2.3.8/docs/Network-HTTP-Conduit.html), which are accessible via an URL with a date in it. The images are stored in an `images` subdirectory with the date in the filename. The program skips URLs that do not return a HTTP status code of `200` (e.g. weekends, holidays, or other periods without images available) and generates an exception if the status code is not in the `2xx` range. The exception is rethrown when the status code is not `404`. This all has no practical use at all but I wanted to see how exceptions are handled in conduits.
<!--more-->

# src/ImageDownloader.hs

Note the `sinkList` and `sourceList`, which are a nice `Conduit` feature and the use of `catchC`.

``` haskell
{-# LANGUAGE ScopedTypeVariables #-}
module ImageDownloader where

import           Control.Exception        (throwIO)
import           Control.Monad            (unless, void, when)
import           Control.Monad.IO.Class   (liftIO)
import           Data.Conduit             (catchC, runConduitRes, (.|))
import qualified Data.Conduit.Binary      as CB
import qualified Data.Conduit.Combinators as CC
import qualified Data.Conduit.List        as CL
import           Data.List.Split          (chunksOf)
import           Data.Time
import           Network.HTTP.Client      (BodyReader, HttpException,
                                           HttpExceptionContent (StatusCodeException),
                                           checkResponse, responseBody,
                                           responseStatus)
import           Network.HTTP.Simple
import           Network.HTTP.Types       (statusCode)
import           System.Directory         (doesFileExist)

outputDir :: String
outputDir = "images/"

statusValid :: Int
statusValid = 200

previousDay :: Day -> Day
previousDay = addDays (-1)

show' :: Int -> String
show' n
  | length (show n) == 1 = "0" ++ show n
  | otherwise = show n

previousDate :: String -> String -> String
previousDate dat yyNow =
  let
    [yy,mm,dd] = chunksOf 2 dat
    (year :: Integer) = read yy
    (month :: Int) = read mm
    (day :: Int) = read dd
    (thisYear :: Integer) = read yyNow
    year' = if year > thisYear then 1900 + year else 2000 + year
    days = fromGregorian year' month day
    pDays = previousDay days
    (pyy,pmm,pdd) = toGregorian pDays
    [_,pyy'] = chunksOf 2 $ show pyy
  in
    pyy' ++ show' pmm ++ show' pdd

-- | Throw 'HttpException' exception on server errors (not 2xx).
checkHttpResponse :: Request -> Response BodyReader -> IO ()
checkHttpResponse request response =
  let sc = statusCode (responseStatus response)
  in
    when (sc `div` 100 /= 2)
      $ throwIO
        $ HttpExceptionRequest
          request
          (StatusCodeException (void response) mempty)

processUrl' :: String -> String -> String -> String -> IO ()
processUrl' yyNow url dat ext = do
  let pathName = outputDir ++ dat ++ ext
  fe <- doesFileExist pathName
  unless fe $ do
    -- rq <- parseRequest fullUrl
    rq' <- parseRequest fullUrl
    let rq = rq' { checkResponse = checkHttpResponse }
    rs <- runConduitRes
      $ (httpSource rq getSrc `catchC`
        (\(e :: HttpException) -> do
             let HttpExceptionRequest _ (StatusCodeException ersp _) = e
                 erspsc = statusCode (responseStatus ersp)
             liftIO $ putStrLn $ " CAUGHT EXCEPTION (HTTP status code=" ++ show erspsc ++ ")"
             when (erspsc /= 404) $
                 liftIO $ throwIO
                   $ HttpExceptionRequest
                     rq
                     (StatusCodeException (void ersp) mempty)))
      .| CC.sinkList
    unless (null rs) $
      runConduitRes
        $ CL.sourceList rs
        .| CB.sinkFile pathName
  processUrl' yyNow url (previousDate dat yyNow) ext
  where
    fullUrl = url ++ dat ++ ext
    getSrc res = do
      let sc = getResponseStatusCode res
      -- Only when status valid; empty result otherwise.
      when (sc == statusValid) $ do
        getResponseBody res
        liftIO $ print (fullUrl, getResponseStatus res, getResponseHeaders res)

processUrl :: String -> String -> String -> IO ()
processUrl url dat ext = do
  now <- getCurrentTime
  let yyNow = formatTime defaultTimeLocale "%y" now
  processUrl' yyNow url dat ext
```

# app/Main.hs

``` haskell
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import qualified Options.Applicative  as OA
import           ImageDownloader

data Args = Args String String String

args :: OA.Parser Args
args = Args
  <$> OA.strArgument
  (OA.metavar "url" <> OA.help "Input is a base url")
  <*> OA.strArgument
  (OA.metavar "date" <> OA.help "Input is a date (yymmdd) section --e.g. 211119")
  <*> OA.strArgument
  (OA.metavar "extension" <> OA.help "Input is a file extension --e.g. .jpg")

argsInfo :: OA.ParserInfo Args
argsInfo = OA.info args OA.fullDesc

main :: IO ()
main = do
  Args url dat ext <- OA.execParser argsInfo
  processUrl url dat ext
```

# package.yaml

Use the `hpack` command to generate a cabal file for the project.

``` yaml
name: imagedownloader
version: 0.0.0.1
synopsis: Image downloader
description: |
    Downloads images with date in URL.
category: HTML
license: GPL-3
stability: development

ghc-options:
- -Wall
- -fno-warn-unused-do-bind
- -fno-warn-name-shadowing
- -fno-warn-missing-signatures
- -fno-warn-type-defaults
- -fno-warn-orphans

library:
  source-dirs: src
  dependencies:
    - base
    - bytestring
    - conduit
    - conduit-extra
    - directory
    - http-client
    - http-conduit
    - http-types
    - resourcet
    - split
    - streaming-commons
    - time

executables:
  imagedownloader:
    main: Main.hs
    source-dirs: app
    ghc-options: [-threaded]
    dependencies:
    - base
    - optparse-applicative
    - imagedownloader
```

# Build and execute

``` bash
hpack
cabal new-build
```

and to execute, use e.g.:

``` bash
cabal new-run . -- http://www.yoursitename.com/images/image 211125 .jpg
```

Which will retrieve all images from the specified date in `yymmdd` format (i.e. 2021, November 25th) backwards in time. Use Ctrl+C to abort the program when there are no more images to download. Watch the output of the program to determine this. The program will not redownload already downloaded images on a subsequent run.
