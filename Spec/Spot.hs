{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

module Spot ( spec ) where

import Spec.SpecHelper
import Data.List
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Lazy    as LBS
import qualified Network.Wai             as Wai
import qualified Database.Persist.Sqlite as P
import qualified Network.Wai.Test        as WaiTest
import App
import DB

testDB = "db/test.sqlite3"
runTestDB = runDB' testDB

getApp = liftIO $ do
  scottyApp $ App.app testDB

getBody res = BS.concat . LBS.toChunks $ WaiTest.simpleBody res

spec :: Spec
spec = do
  let withData = bracket_ setup teardown
           where
             setup =
               runTestDB $ P.insert $ Spot 1.2 1.3 "ABCDE"
             teardown =
               runTestDB $ P.deleteWhere ([] :: [P.Filter Spot])

  describe "GET /" $ do
    it "should contains 'haskell' in response body" $ do
      app <- getApp
      res <- WaiTest.runSession (WaiTest.request initReq) app
      "Haskell" `BS.isInfixOf` (getBody res) `shouldBe` True

  describe "GET /spots" $ do
    it "should contains 'ABCDE' in response body" $ do
      withData $ do
        app <- getApp
        res <- app `getReq` "/spots"
        liftIO $ print $ (getBody res)
        "ABCDE" `BS.isInfixOf` (getBody res) `shouldBe` True

main = spec
