+++
author = "Mari Donkers"
title = "Encrypted fields in JSON settings file"
date = "2022-11-25"
description = "The Haskell cryptonite package is used to allow for encrypted fields in a JSON settings file. Source code listed below."
featured = false
tags = [
    "Computer",
    "Software",
    "Functional Programming",
    "Haskell",
    "Cryptography",
    "Internet",
    "JSON",
]
categories = [
    "haskell",
    "cryptography",
]
series = ["Haskell", "Cryptography"]
aliases = ["2022-11-25-haskell-cryptonite-encrypted-json-settings-file"]
thumbnail = "/images/cryptography.png"
+++

The Haskell [cryptonite](https://hackage.haskell.org/package/cryptonite) package is used to allow for encrypted fields in a JSON settings file. Source code listed below.
<!--more-->

# Example JSON settings file

``` json
{"_apiKey":"f0KBfirFsznsAr/4s3q4TYpawUumsVGeBg==","_apiKeySecurity":{"_initIV":"nyT7ZdnFD4+8BJ9rHFMrFQ==","_salt":"1uEgA3kzWZBU5vqr/AKhhtwhCCCkuXZmTsVVbILilcU="},"_apiSecret":"y1UGRtm3IGMDKPb4I9pR/KmO8+gjyMScxeRBfw==","_apiSecretSecurity":{"_initIV":"Bpj0VfEVtwor0GQzKRVraA==","_salt":"BnC1a9BlmnK+FzZIVRnZwub74lhyZQgdW8JClKLkxq4="},"_dbConnectionUriPostfix":"db/binance-api.db","_dbConnectionUriPrefix":"sqlite://"}
```

# Settings.hs

``` haskell
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Mammon.Settings where

import Control.Lens
import Control.Monad (unless, when)
import Crypto.Cipher.AES (AES256)
import Data.Aeson
import Data.ByteArray (unpack)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import GHC.Generics
import qualified Mammon.Security as MS
import qualified Mammon.Types as MT
import qualified Mammon.Utils as MU
import System.Directory (createDirectoryIfMissing, doesFileExist)
import System.FilePath (addTrailingPathSeparator)

settingsPath :: FilePath
settingsPath = ".binance"

settingsFile :: FilePath
settingsFile = "binance-api-settings.json"

data AppSettingsSecurity = AppSettingsSecurity
  { _initIV :: T.Text,
    _salt :: T.Text
  }
  deriving (Generic, Read, Show, FromJSON, ToJSON)

makeLenses ''AppSettingsSecurity

data AppSettings = AppSettings
  { _apiKey :: T.Text,
    _apiKeySecurity :: AppSettingsSecurity,
    _apiSecret :: T.Text,
    _apiSecretSecurity :: AppSettingsSecurity,
    _dbConnectionUriPrefix :: T.Text,
    _dbConnectionUriPostfix :: T.Text
  }
  deriving (Generic, Read, Show, FromJSON, ToJSON)

makeLenses ''AppSettings

mkAppSettings =
  AppSettings
    { _apiKey = "binance-api-key-goes-here",
      _apiKeySecurity =
        AppSettingsSecurity
          { _initIV = "",
            _salt = ""
          },
      _apiSecret = "binance-api-secret-goes-here",
      _apiSecretSecurity =
        AppSettingsSecurity
          { _initIV = "",
            _salt = ""
          },
      _dbConnectionUriPrefix = "sqlite://",
      _dbConnectionUriPostfix = "db/binance-api.db"
    }

getAppBinanceApiKey :: Either String AppSettings -> T.Text
getAppBinanceApiKey eas = case eas of
  Left e -> T.pack e
  Right a -> _apiKey a

getAppBinanceApiKeySecurity :: Either String AppSettings -> (T.Text, T.Text)
getAppBinanceApiKeySecurity eas = case eas of
  Left e -> let pe = T.pack e in (pe, pe)
  Right a ->
    let ak = _apiKeySecurity a
     in (_initIV ak, _salt ak)

getAppBinanceApiSecret :: Either String AppSettings -> T.Text
getAppBinanceApiSecret eas = case eas of
  Left e -> T.pack e
  Right a -> _apiSecret a

getAppBinanceApiSecretSecurity :: Either String AppSettings -> (T.Text, T.Text)
getAppBinanceApiSecretSecurity eas = case eas of
  Left e -> let pe = T.pack e in (pe, pe)
  Right a ->
    let ak = _apiSecretSecurity a
     in (_initIV ak, _salt ak)

getAppBinanceDbUri :: FilePath -> Either String AppSettings -> T.Text
getAppBinanceDbUri fp eas = case eas of
  Left e -> T.pack e
  Right a -> _dbConnectionUriPrefix a <> T.pack (addTrailingPathSeparator fp) <> _dbConnectionUriPostfix a

readSettings :: FilePath -> MS.SecurityKey -> MT.Verbosity -> IO (Either String AppSettings)
readSettings binanceApiHome securityKey verbosity = do
  appSettings <- getSettingsFromFile binanceApiHome
  decryptSettings appSettings
  where
    getSettingsFromFile bah = do
      let sfd = addTrailingPathSeparator bah <> addTrailingPathSeparator settingsPath
          sfn = sfd <> settingsFile
      settingsExists <- checkSettingsExist sfd sfn
      when (verbosity == MT.Verbose) $
        putStrLn $
          "Settings file "
            <> sfn
            <> " "
            <> if settingsExists
              then "EXISTS"
              else "CREATING (now edit Binance secret and -key in your settings file; execute encodeSettings with chosen securityKey"
      unless settingsExists $ do
        BL.writeFile sfn $ encode mkAppSettings
      (eitherDecode <$> getJSON sfn) :: IO (Either String AppSettings)
    decryptSettings :: Either String AppSettings -> IO (Either String AppSettings)
    decryptSettings as = do
      let apk = getAppBinanceApiKey as
          (apksi, apkss) = getAppBinanceApiKeySecurity as
          aps = getAppBinanceApiSecret as
          (apssi, apsss) = getAppBinanceApiSecretSecurity as
      eak <- decryptWithSecurityKey securityKey apksi apkss (MU.b64ToBS apk)
      let eakt = TE.decodeUtf8 eak
      eas <- decryptWithSecurityKey securityKey apssi apsss (MU.b64ToBS aps)
      let east = TE.decodeUtf8 eas
      pure $ case as of
        Left e -> Left e
        Right as' -> Right $ as' & apiKey .~ eakt & apiSecret .~ east

decryptWithSecurityKey :: MS.SecurityKey -> T.Text -> T.Text -> BS.ByteString -> IO BS.ByteString
decryptWithSecurityKey sk pInitIV pSalt pd = do
  mInitIV <- MS.mkIV (undefined :: AES256) $ MU.b64ToBS pInitIV
  let salt = MU.b64ToBS pSalt
      key = MS.deriveKey sk salt
  case mInitIV of
    Nothing -> error "Failed to read the initialization vector (have you run with -e to encrypt plaintext Binance secret and -key?)"
    Just initIV -> do
      pure $ MS.decrypt key initIV pd

encodeSettings :: FilePath -> MS.SecurityKey -> MT.Verbosity -> IO (Either String AppSettings)
encodeSettings binanceApiHome securityKey verbosity = do
  let sfd = addTrailingPathSeparator binanceApiHome <> addTrailingPathSeparator settingsPath
      sfn = sfd <> settingsFile
  appSettings <- initializeAppSettingsFile sfd sfn
  encryptSettings appSettings sfn
  where
    initializeAppSettingsFile sfd sfn = do
      settingsExists <- checkSettingsExist sfd sfn
      unless settingsExists $ do
        BL.writeFile sfn $ encode mkAppSettings
      when (verbosity == MT.Verbose) $
        putStrLn $
          "Settings file "
            <> sfn
            <> " "
            <> if settingsExists
              then "EXISTS"
              else "CREATING"
      (eitherDecode <$> getJSON sfn) :: IO (Either String AppSettings)
    encryptSettings :: Either String AppSettings -> FilePath -> IO (Either String AppSettings)
    encryptSettings as sfn = do
      let apk = getAppBinanceApiKey as
          aps = getAppBinanceApiSecret as
      (ik, sk, eak) <- encryptWithSecurityKey securityKey (TE.encodeUtf8 apk)
      (is, ss, eas) <- encryptWithSecurityKey securityKey (TE.encodeUtf8 aps)
      case as of
        Left e -> pure $ Left e
        Right as' ->
          do
            let as'' =
                  as'
                    & apiKey .~ MU.b64FromBS eak
                    & apiKeySecurity .~ AppSettingsSecurity {_initIV = ik, _salt = sk}
                    & apiSecret .~ MU.b64FromBS eas
                    & apiSecretSecurity .~ AppSettingsSecurity {_initIV = is, _salt = ss}
            BL.writeFile sfn $ encode as''
            pure $ Right as''

encryptWithSecurityKey :: MS.SecurityKey -> BS.ByteString -> IO (T.Text, T.Text, BS.ByteString)
encryptWithSecurityKey sk pd = do
  salt <- MS.random MS.saltSize
  mInitIV <- MS.genRandomIV (undefined :: AES256)
  case mInitIV of
    Nothing -> error "Failed to generate a random initialization vector (check your software source code)."
    Just initIV -> do
      let key = MS.deriveKey sk salt
      let initIV' = MU.b64FromW8Array $ unpack initIV
      let salt' = MU.b64FromBS salt
      pure (initIV', salt', MS.encrypt key initIV pd)

-- | Checks for existing settings.
checkSettingsExist sfd sfn = do
  createDirectoryIfMissing True sfd
  doesFileExist sfn

-- | Get JSON from file denoted by path.
getJSON :: FilePath -> IO BL.ByteString
getJSON = BL.readFile
```

# Security.hs

``` haskell
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Mammon.Security where

import Crypto.Cipher.AES (AES256)
import Crypto.Cipher.Types (BlockCipher (..), Cipher (..), IV, makeIV)
import Crypto.Error (throwCryptoError)
import Crypto.KDF.Scrypt (Parameters (..), generate)
import Crypto.Random (getSystemDRG, randomBytesGenerate)
import qualified Crypto.Random.Types as CRT
import qualified Data.ByteString as BS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Word

saltSize :: Int
saltSize = 32

paramN = 16 :: Word64

paramR = 8

paramP = 1

paramKeyLen = 32

type SecurityKey = T.Text

-- | AES256 encryption
encrypt :: BS.ByteString -> IV AES256 -> BS.ByteString -> BS.ByteString
encrypt key = ctrCombine ctx
  where
    ctx :: AES256
    ctx = throwCryptoError $ cipherInit key

-- | i.e. encrypt (because symmetrical)
decrypt :: BS.ByteString -> IV AES256 -> BS.ByteString -> BS.ByteString
decrypt = encrypt

-- | Generate a random initialization vector for a given block cipher
genRandomIV :: forall m c. (CRT.MonadRandom m, BlockCipher c) => c -> m (Maybe (IV c))
genRandomIV _ = do
  bytes :: BS.ByteString <- CRT.getRandomBytes $ blockSize (undefined :: c)
  return $ makeIV bytes

mkIV :: forall m c. (CRT.MonadRandom m, BlockCipher c) => c -> BS.ByteString -> m (Maybe (IV c))
mkIV _ iv = do
  let bytes :: BS.ByteString = iv
  return $ makeIV bytes

-- | Scrypt KDF
--
-- `password` security key
-- `salt` salt value
deriveKey :: T.Text -> BS.ByteString -> BS.ByteString
deriveKey password = generate params (TE.encodeUtf8 password)
  where
    params = Parameters {n = paramN, r = paramR, p = paramP, outputLength = paramKeyLen}

-- | For generating the salt
random :: Int -> IO BS.ByteString
random size = do
  drg <- getSystemDRG
  let (bytes, _) = randomBytesGenerate size drg
  return bytes
```

# Utils.hs

``` haskell
module Mammon.Utils where

import Data.ByteArray.Encoding (Base (Base64), convertFromBase, convertToBase)
import qualified Data.ByteString as BS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import GHC.Word (Word8)

b64FromBS :: BS.ByteString -> T.Text
b64FromBS bs = TE.decodeUtf8 (convertToBase Base64 bs :: BS.ByteString)

b64ToBS :: T.Text -> BS.ByteString
b64ToBS ts = case convertFromBase Base64 (TE.encodeUtf8 ts) :: Either String BS.ByteString of
  Left e -> TE.encodeUtf8 (T.pack e)
  Right bs -> bs

b64FromW8Array :: [Word8] -> T.Text
b64FromW8Array = b64FromBS . BS.pack

b64ToW8Array :: T.Text -> [Word8]
b64ToW8Array = BS.unpack . b64ToBS

```

# Types.hs

``` haskell
module Mammon.Types where

data Verbosity = Normal | Verbose deriving (Eq)

data Connection = Connected | Disconnected deriving (Eq)

data Trading = Unarmed | Armed deriving (Eq)
```

# Disclaimer

[Ter leering ende vermaeck](https://onzetaal.nl/taalloket/ter-leering-ende-vermaeck)

This code appears to work, but I have not battle tested it, hence no guarantees are given at all! Specifically the `paramN`, `paramR` and `paramP` values for `deriveKey` may need revising — see the [Crypto.KDF.Scrypt](https://hackage.haskell.org/package/cryptonite-0.30/docs/Crypto-KDF-Scrypt.html) documentation.

Use this software at your own risk — [caveat emptor](https://www.law.cornell.edu/wex/caveat_emptor)!
