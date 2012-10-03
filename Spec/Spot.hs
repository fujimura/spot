{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

module Spec.Spot ( spec ) where

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
  let withData = bracket_ setup teardown
           where
             setup =
               runDB p $ P.insert $ Spot 1.2 1.3 "ABCDE"
             teardown =
               runDB p $ P.deleteWhere ([] :: [P.Filter Spot])

  describe "GET /" $
    it "should contains 'haskell' in response body" $ do
      app <- getApp p
      res <- app `get` ""
      getBody res `shouldContains` "Haskell"

  describe "GET /spots" $
    it "should contains 'ABCDE' in response body" $ withData $ do
      app <- getApp p
      res <- app `get` "spots"
      getBody res `shouldContains` "ABCDE"

  describe "GET /spots/:id" $
    it "should get record" $ do
      k <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      spot <- runDB p $ P.get k
      app    <- getApp p
      res    <- get app (BS.concat ["spots/", (BSC8.pack $ show k)])
      (BS.concat . LBS.toChunks $ AE.encode spot) `shouldEqual` (getBody res)

  describe "POST /spots" $
    it "should create new Spot record" $ do
      let spot = Spot 1.2 1.3 "ABCDE"
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      res    <- post app "spots" $ AE.encode spot
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before < after `shouldBe` True

  describe "PUT /spots/:id" $
    it "should update existing record" $ do
      spotId <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app    <- getApp p
      _      <- put app (BS.concat ["spots/", (BSC8.pack $ show spotId)]) $ AE.encode (Spot 1.2 1.3 "BAR")
      spot   <- runDB p $ P.get spotId
      case spot of
          Just s -> (spotBody s) `shouldEqual` "BAR"
          Nothing -> error "Failed to create Spot record"

  describe "DELETE /spots/:id" $
    it "should delete existing record" $ do
      spotId <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      _      <- delete app (BS.concat ["spots/", (BSC8.pack $ show spotId)])
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before - after `shouldBe` 1

main = spec
