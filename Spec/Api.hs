{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

module Spec.Api ( spec ) where

import           Control.Exception       (finally)
import qualified Data.Aeson              as AE
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Char8   as BSC8
import qualified Data.ByteString.Lazy    as LBS
import           Data.Text.Encoding
import qualified Database.Persist.Sqlite as P
import           DB
import           Helper
import           Spec.Helper
import           Web.PathPieces

spec :: P.ConnectionPool -> Spec
spec p = do
  let cleanup = finally $ runDB p $ P.deleteWhere ([] :: [P.Filter Spot])

  describe "GET /spots" $ do
    it "should contains 'ABCDE' in response body" $ cleanup $ do
      key      <- runDB p $ P.insert $ Spot 1.2 1.3 "ABCDE"
      resource <- runDB p $ P.get key
      app      <- getApp p
      response <- app `get` "spots"
      getBody response `shouldContains` (BS.concat $ LBS.toChunks $ AE.encode resource)

  describe "GET /spots/:id" $ do
    it "should get record" $ cleanup $ do
      key      <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      resource <- runDB p $ P.get key
      app      <- getApp p
      response <- get app (BS.concat ["spots/", (encodeUtf8 $ toPathPiece key)])
      (BS.concat . LBS.toChunks $ AE.encode resource) `shouldEqual` (getBody response)

    it "should return 404 if resource is not found" $ cleanup $ do
      app      <- getApp p
      response <- get app "spots/1023"
      (getStatus response) `shouldEqual` 404

  describe "POST /spots" $ do
    it "should create new Spot record" $ cleanup $ do
      let resource = Spot 1.2 1.3 "ABCDE"
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      res    <- post app "spots" $ AE.encode resource
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before < after `shouldBe` True

    describe "with invalid JSON" $ do
      let request = do
          app    <- getApp p
          post app "spots" $ "INVALID JSON{{{{"

      it "should return 400" $ do
        response <- request
        (getStatus response) `shouldEqual` 400

      it "should return invalid JSON itself" $ do
        response <- request
        (getBody response) `shouldContains` "\"message\":\"Invalid JSON format: INVALID JSON{{{{\""

  describe "PUT /spots/:id" $ do
    it "should update existing record" $ cleanup $ do
      key <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app <- getApp p
      _   <- put app (BS.concat ["spots/", (encodeUtf8 $ toPathPiece key)]) $ AE.encode (Spot 1.2 1.3 "BAR")
      resource   <- runDB p $ P.get key
      case resource of
          Just s -> (spotBody s) `shouldEqual` "BAR"
          Nothing -> error "Failed to create Spot record"

    it "should return 404 if resource is not found" $ cleanup $ do
      _ <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app <- getApp p
      response <- put app "spots/8392" $ AE.encode (Spot 1.2 1.3 "BAR")
      (getStatus response) `shouldEqual` 404

    describe "with invalid JSON" $ do
      let request = do
          key <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
          app <- getApp p
          put app (BS.concat ["spots/", (encodeUtf8 $ toPathPiece key)]) $ "INVALID JSON{{{{"

      it "should return 400" $ do
        response <- request
        (getStatus response) `shouldEqual` 400

      it "should return invalid JSON itself" $ do
        response <- request
        (getBody response) `shouldContains` "\"message\":\"Invalid JSON format: INVALID JSON{{{{\""

  describe "DELETE /spots/:id" $ do
    it "should delete existing record" $ cleanup $ do
      key    <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app    <- getApp p
      before <- runDB p $ P.count ([] :: [P.Filter Spot])
      _      <- delete app (BS.concat ["spots/", (encodeUtf8 $ toPathPiece key)])
      after  <- runDB p $ P.count ([] :: [P.Filter Spot])
      before - after `shouldBe` 1

    it "should return 404 if resource is not found" $ cleanup $ do
      _ <- runDB p $ P.insert (Spot 1.2 1.3 "FOO")
      app <- getApp p
      response <- delete app "spots/300000"
      (getStatus response) `shouldEqual` 404
