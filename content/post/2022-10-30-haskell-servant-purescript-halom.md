+++
author = "Mari Donkers"
title = "Servant server + Halo client"
date = "2022-10-30"
description = "The Haskell-realworld-example Haskell example (Servant based server) and the Real World PureScript React Purescript example (client) combined into Conduit."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "PureScript",
    "Internet",
    "HTML",
    "JavaScript",
    "API",
    "Nix",
    "Webgear",
]
categories = [
    "linux",
    "haskell",
    "purescript",
]
series = ["Linux", "Haskell", "PureScript"]
aliases = ["2022-10-30-haskell-servant-purescript-halom"]
thumbnail = "/images/purescript.png"
+++

The [Haskell-realworld-example](https://github.com/nodew/haskell-realworld-example) `Haskell` example ([Servant](https://docs.servant.dev/en/stable/) based server) and the [Real World PureScript React](https://github.com/jonasbuntinx/purescript-react-realworld) `Purescript` example (client) combined into `Conduit` ([gothinkster/realworld](https://github.com/gothinkster/realworld)) — what's described as "The mother of all demo apps" (fullstack Medium.com clone)
<!--more-->

# Introduction

Haskell-realworld-example has a very nice implementation for [JWT authentication](https://blog.miniorange.com/what-is-jwt-json-web-token-how-does-jwt-authentication-work/), which combines nicely with the Real World PureScript React example (although there are some implementation differences to iron out).

# Implementation differences

## JWT

### Changes to the client

In `Conduit.Data.Jwt` change `username` to `sub`.

``` haskell
type Jwt =
{ sub :: Username
, exp :: Number
}
...
CAR.object "Jwt"
              { sub: usernameCodec -- username: usernameCodec -- TODO fix
              , exp: CA.number
              }
```

In `Conduit.Data.Auth` change `username` to `sub`.

``` haskell
{ exp, username } <- hush $ Jwt.decode token
pure { token, username, expirationTime: fromMilliseconds $ Milliseconds $ exp * 1000.0, user }
```

### Changes to the server

In `Conduit.JWT` you'll problably want to change `mkClaims` to use your own names for `iss` and `aud`.

``` haskell
mkClaims :: Username -> IO ClaimsSet
mkClaims name = do
    currentTime <- getCurrentTime
    let expiredAt = addUTCTime nominalDay currentTime
    pure $ emptyClaimsSet
        & claimIss ?~ "conduit-server"
        & claimAud ?~ Audience ["conduit-client"]
        & claimIat ?~ NumericDate currentTime
        & claimExp ?~ NumericDate expiredAt
        & claimSub ?~ (fromString . T.unpack . getUsername) name
```

## Empty image field in login response

The server returns apparently valid JSON — hence weird problem — with an empty `image` field, but the client reports a decoding error. If the image field is set to a value (by changing it directly in the users table in the database as a workaround) then it functions correctly; even though the `bio` field is also empty — even weirder.

****This may be because an empty field should not be sent by the server (when it's an optional field).****

Then again, if the server wants to send an optional empty field then that should be optional?

``` json
{
   "user" : {
      "bio" : "",
      "email" : "arya@winterfell.com",
      "image" : "",
      "token" : "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYWxkci1jbGllbnQiLCJleHAiOjEuNjY3MjA1NjIxMDE1MzQ5MzE5ZTksImlhdCI6MS42NjcxMTkyMjEwMTUzNDkzMTllOSwiaXNzIjoiYmFsZHItc2VydmVyIiwic3ViIjoiQXJ5YSAxIn0.TzhDvT9Mkmj9nalh_q7vGol-IbnRRoxoiGPQwlasaGQ",
      "username" : "Arya 1"
   }
}
```

Console error logging:

``` example
(DecodeError { body: "{\"user\":{\"email\":\"arya@winterfell.com\",\"password\":\"valar_morghulis\"}}", headers: [(ContentType (MediaType "application/json"))], method: POST, url: "/api/users/login" } { body: "{\"user\":{\"bio\":\"\",\"email\":\"arya@winterfell.com\",\"image\":\"\",\"token\":\"eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYWxkci1jbGllbnQiLCJleHAiOjEuNjY3MjA1NjIxMDE1MzQ5MzE5ZTksImlhdCI6MS42NjcxMTkyMjEwMTUzNDkzMTllOSwiaXNzIjoiYmFsZHItc2VydmVyIiwic3ViIjoiQXJ5YSAxIn0.TzhDvT9Mkmj9nalh_q7vGol-IbnRRoxoiGPQwlasaGQ\",\"username\":\"Arya 1\"}}", headers: [(ResponseHeader "connection" "keep-alive"),(ResponseHeader "content-type" "application/json;charset=utf-8"),(ResponseHeader "date" "Sun, 30 Oct 2022 08:40:21 GMT"),(ResponseHeader "server" "nginx/1.21.6"),(ResponseHeader "transfer-encoding" "chunked")], status: (StatusCode 200) } An error occurred while decoding a JSON value:
  Under 'Response':
  At object key user:
  Under 'User':
  At object key image:
  Under 'Maybe':
  Under 'Avatar':
  Unexpected value "".)
```

The client code has different codecs for `image` and `bio`

`Conduit.Data.Profile`

``` haskell
-- | Codecs
mkProfileRepCodec :: forall rest. CA.JPropCodec (Record rest) -> CA.JPropCodec { | ProfileRep rest }
mkProfileRepCodec =
  CA.recordProp (Proxy :: Proxy "username") usernameCodec
    <<< CA.recordProp (Proxy :: Proxy "bio") (CAC.maybe CA.string)
    <<< CA.recordProp (Proxy :: Proxy "image") (CAC.maybe avatarCodec)
```

but avatarCodec is also a string in the end

`Conduit.Data.Avatar`

``` haskell
-- | Codecs
avatarCodec :: JsonCodec Avatar
avatarCodec = CA.prismaticCodec "Avatar" fromString toString CA.string
```

hence weird.

****WORKAROUND****

In `Conduit.Data.Avatar` change fromString to the following<sup>1</sup>:

``` haskell
fromString :: String -> Maybe Avatar
fromString str
  | String.null str = Just (Avatar "")
  | otherwise = Just (Avatar str)
```

Beware: now there's no longer no avatar (which might be bad, but still better than the alternative).

<sup>1</sup> One could even use `fromString str = Just (Avatar str)` but that would probably be even more confusing.

## Token in User update response

The server doesn't return a `token` field, but the client expects it. The [update user](https://realworld-docs.netlify.app/docs/specs/backend-specs/endpoints#update-user) section in the Realworld spec also mentions it (hence issue in server).

Also the password is changed to something you no longer know, hence logging in is impossible after a user update (it's probably a `bug`).

``` example
(DecodeError { body: "null", headers: [(ContentType (MediaType "application/json")),(RequestHeader "Authorization" "Token eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYWxkci1jbGllbnQiLCJleHAiOjEuNjY3MjA1NjM3MjcwMTAyMzcyZTksImlhdCI6MS42NjcxMTkyMzcyNzAxMDIzNzJlOSwiaXNzIjoiYmFsZHItc2VydmVyIiwic3ViIjoiQXJ5YSAxIn0.tQ4JqPXoBu7RDSjF0gJeBi8NDJFGp7w7D8cxjUXMUno")], method: GET, url: "/api/user" } { body: "{\"user\":{\"bio\":\"\",\"email\":\"arya@winterfell.com\",\"image\":\"smiley-cyrus.09f77aa9.jpg\",\"username\":\"Arya 1\"}}", headers: [(ResponseHeader "connection" "keep-alive"),(ResponseHeader "content-type" "application/json;charset=utf-8"),(ResponseHeader "date" "Sun, 30 Oct 2022 10:42:00 GMT"),(ResponseHeader "server" "nginx/1.21.6"),(ResponseHeader "transfer-encoding" "chunked")], status: (StatusCode 200) } An error occurred while decoding a JSON value:
  Under 'UserResponse':
  At object key user:
  Under 'User':
  At object key token:
  No value was found.) index.b98cbc1b.js:1:50285
```

## Forbidden characters in slugs

The server doesn't check if the characters in the title (which are used to create the slug) are valid. This can be fixed by e.g. using the [slugger](https://github.com/rpearce/slugger) library.

`stack.yaml`

``` yaml
resolver: lts-19.31
...
extra-deps:
  - slugger-0.1.0.1@sha256:b6c37b0d4c2d35a49ad20e9978bf0ce308a8c4455fc61d0b446db1f3971bdc28,2035

nix:
  pure: true
  enable: true
  packages: [ postgresql zlib icu]
```

(trying out `resolver: lts-19.31` — the nix section is for use with `NixOS`)

`package.yaml`

``` yaml
...
  dependencies:
...      
  - slugger
...
```

(Add slugger to depencies)

`Conduit.Core.Article`

``` haskell
...
import Data.Text.Slugger (toSlug)
...
mkSlug :: MonadIO m => Text -> m Slug
mkSlug title = do
    rnd <- liftIO $ getRandomBytes 32
    let hash = T.pack $ show $ hashWith SHA256 (rnd :: ByteString)
    let title' = toSlug title
    let slugText = T.intercalate "-" $ (T.words . T.toLower $ title') ++ [T.take 8 hash]
    return $ Slug slugText
...
```

## Comments don't work

Completely breaks the client; reload of page and re-login needed.
