{-# LANGUAGE OverloadedStrings #-}

module Spec.Helper
  (
    module X
  , bracket_
  , get
  , post
  , put
  , getApp
  , getBody
  , migrate
  , shouldContains
  , shouldEqual
  ) where

import Control.Monad.Trans as X
import Control.Applicative as X
import Test.Hspec          as X

import Control.Exception (bracket_)
import Data.Monoid (mempty)

import qualified Data.Text                as T
import qualified Data.Text.Encoding       as TE
import qualified Data.ByteString          as BS
import qualified Data.ByteString.Lazy     as LBS
import qualified Data.Aeson               as AE
import qualified Data.Conduit.List        as CL
import qualified Codec.Binary.UTF8.String as CBUS
import qualified Network.Wai              as W
import qualified Network.Wai.Test         as WT
import qualified Network.Socket.Internal  as Sock
import qualified Network.HTTP.Types       as HT
import qualified Database.Persist.Sqlite  as P
import qualified Web.Scotty               as Scotty

import qualified DB
import qualified App

get :: W.Application -> BS.ByteString -> IO WT.SResponse
get app path =
  WT.runSession (WT.srequest (WT.SRequest req "")) app
      where req = WT.setRawPathInfo WT.defaultRequest path

post :: W.Application -> BS.ByteString -> LBS.ByteString -> IO WT.SResponse
post app path body =
  WT.runSession (WT.srequest (WT.SRequest req body)) app
      where req = flip WT.setRawPathInfo path WT.defaultRequest {
          W.requestMethod  = HT.methodPost
      }

put :: W.Application -> BS.ByteString -> LBS.ByteString -> IO WT.SResponse
put app path body =
  WT.runSession (WT.srequest (WT.SRequest req body)) app
      where req = flip WT.setRawPathInfo path WT.defaultRequest {
          W.requestMethod  = HT.methodPut
      }

migrate :: P.ConnectionPool -> IO ()
migrate p = liftIO $ DB.runDB p $ P.runMigration DB.migrateAll

getApp :: P.ConnectionPool -> IO W.Application
getApp p = liftIO $ Scotty.scottyApp $ App.app p

getBody :: WT.SResponse -> BS.ByteString
getBody res = BS.concat . LBS.toChunks $ WT.simpleBody res

should :: Show a => (a -> a -> Bool) -> a -> a -> Expectation
should be actual expected = actual `be` expected `shouldBe` True

shouldContains :: BS.ByteString -> BS.ByteString -> Expectation
shouldContains subject matcher = should BS.isInfixOf matcher subject

shouldEqual :: (Show a, Eq a) => a -> a -> Expectation
shouldEqual = should (==)
