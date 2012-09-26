{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

module Spec.Spot ( spec ) where

import Spec.Helper
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Lazy    as LBS
import qualified Data.Aeson              as AE
import qualified Database.Persist.Sqlite as P
import DB

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
      res <- app `get` "/"
      getBody res `shouldContains` "Haskell"

  describe "GET /spots" $
    it "should contains 'ABCDE' in response body" $ withData $ do
      app <- getApp p
      res <- app `get` "/spots"
      getBody res `shouldContains` "ABCDE"

  describe "POST /spots" $
    it "should create new Spot record" $ do
      let spot = Spot 1.2 1.3 "ABCDE"
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      res    <- post app "/spots" $ AE.encode spot
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before < after `shouldBe` True

main = spec
