{-# LANGUAGE OverloadedStrings #-}

module Spec.Helper
  (
    module X
  , bracket_
  , get
  , post
  , put
  , delete
  , getApp
  , getBody
  , getStatus
  , migrate
  , shouldContains
  , shouldEqual
  ) where

import           Control.Applicative      as X
import           Control.Monad.Trans      as X
import           Test.Hspec               as X

import           Control.Exception        (bracket_)
import           Data.Monoid              (mempty)

import qualified Codec.Binary.UTF8.String as CBUS
import qualified Data.Aeson               as AE
import qualified Data.ByteString          as BS
import qualified Data.ByteString.Lazy     as LBS
import qualified Data.Conduit.List        as CL
import qualified Data.Text                as T
import qualified Data.Text.Encoding       as TE
import qualified Database.Persist.Sqlite  as P
import qualified Network.HTTP.Types       as HT
import qualified Network.Socket.Internal  as Sock
import qualified Network.Wai              as W
import qualified Network.Wai.Test         as WT
import           Web.PathPieces
import qualified Web.Scotty               as Scotty

import qualified Api
import qualified App
import qualified DB

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

delete :: W.Application -> BS.ByteString -> IO WT.SResponse
delete app path =
  WT.runSession (WT.srequest (WT.SRequest req "")) app
      where req = flip WT.setRawPathInfo path WT.defaultRequest {
          W.requestMethod  = HT.methodDelete
      }

migrate :: P.ConnectionPool -> IO ()
migrate p = liftIO $ DB.runDB p $ P.runMigration DB.migrateAll

getApp :: P.ConnectionPool -> IO W.Application
getApp p = liftIO $ Scotty.scottyApp $ do
              App.app
              Api.app p

getBody :: WT.SResponse -> LBS.ByteString
getBody res = WT.simpleBody res

getStatus :: WT.SResponse -> Int
getStatus = HT.statusCode . WT.simpleStatus

should :: Show a => (a -> a -> Bool) -> a -> a -> Expectation
should be actual expected = actual `be` expected `shouldBe` True

shouldContains :: LBS.ByteString -> LBS.ByteString -> Expectation
shouldContains subject matcher = should contains matcher subject
    where
      contains m s = any (LBS.isPrefixOf m) $ LBS.tails s

shouldEqual :: (Show a, Eq a) => a -> a -> Expectation
shouldEqual = should (==)
