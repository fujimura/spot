{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

module Spec.Spot ( spec ) where

import Spec.Helper
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Lazy    as LBS
import qualified Database.Persist.Sqlite as P
import qualified Network.Wai.Test        as WaiTest
import DB

spec :: P.ConnectionPool -> Spec
spec p = do
  let withData = bracket_ setup teardown
           where
             setup =
               runDB p $ P.insert $ Spot 1.2 1.3 "ABCDE"
             teardown =
               runDB p $ P.deleteWhere ([] :: [P.Filter Spot])

  describe "GET /" $ do
    it "should contains 'haskell' in response body" $ do
      app <- getApp p
      res <- app `get` "/"
      liftIO $ print (getBody res)
      "Haskell" `BS.isInfixOf` (getBody res) `shouldBe` True

  describe "GET /spots" $
    it "should contains 'ABCDE' in response body" $ do
      withData $ do
        app <- getApp p
        res <- app `get` "/spots"
        "ABCDE" `BS.isInfixOf` (getBody res) `shouldBe` True

main = spec
