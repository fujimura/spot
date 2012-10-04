{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

module Spec.Api ( spec ) where

import           Control.Exception       (finally)
import qualified Data.Aeson              as AE
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Char8   as BSC8
import qualified Data.ByteString.Lazy    as LBS
import qualified Database.Persist.Sqlite as P
import           DB
import           Spec.Helper
import           System.IO

spec :: P.ConnectionPool -> Spec
spec p = do
  let cleanup = finally $ runDB p $ P.deleteWhere ([] :: [P.Filter Spot])

  describe "GET /spots" $
    it "should contains 'ABCDE' in response body" $ cleanup $ do
      runDB p $ P.insert $ Spot 1.2 1.3 "ABCDE"
      app <- getApp p
      res <- app `get` "spots"
      getBody res `shouldContains` "ABCDE"

  describe "GET /spots/:id" $
    it "should get record" $ cleanup $ do
      key      <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      resource <- runDB p $ P.get key
      app      <- getApp p
      response <- get app (BS.concat ["spots/", (BSC8.pack $ show key)])
      (BS.concat . LBS.toChunks $ AE.encode resource) `shouldEqual` (getBody response)

  describe "POST /spots" $
    it "should create new Spot record" $ cleanup $ do
      let resource = Spot 1.2 1.3 "ABCDE"
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      res    <- post app "spots" $ AE.encode resource
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before < after `shouldBe` True

  describe "PUT /spots/:id" $
    it "should update existing record" $ cleanup $ do
      key <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app <- getApp p
      _   <- put app (BS.concat ["spots/", (BSC8.pack $ show key)]) $ AE.encode (Spot 1.2 1.3 "BAR")
      resource   <- runDB p $ P.get key
      case resource of
          Just s -> (spotBody s) `shouldEqual` "BAR"
          Nothing -> error "Failed to create Spot record"

  describe "DELETE /spots/:id" $
    it "should delete existing record" $ cleanup $ do
      key    <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      _      <- delete app (BS.concat ["spots/", (BSC8.pack $ show key)])
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before - after `shouldBe` 1
