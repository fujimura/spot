{-# LANGUAGE OverloadedStrings #-}

module Spec.Helper
  (
    module X
  , bracket_
  , get
  , post
  , getApp
  , getBody
  , migrate
  , shouldContains
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
import qualified Network.Wai              as Wai
import qualified Network.Wai.Test         as WaiTest
import qualified Network.Socket.Internal  as Sock
import qualified Network.HTTP.Types       as HT
import qualified Database.Persist.Sqlite  as P
import qualified Web.Scotty               as Scotty

import qualified DB
import qualified App

get :: Wai.Application -> BS.ByteString -> IO WaiTest.SResponse
get app path =
  WaiTest.runSession (WaiTest.srequest (WaiTest.SRequest req "")) app
      where req = WaiTest.setRawPathInfo WaiTest.defaultRequest path

post :: Wai.Application -> BS.ByteString -> LBS.ByteString -> IO WaiTest.SResponse
post app path body =
  WaiTest.runSession (WaiTest.srequest (WaiTest.SRequest req body)) app
      where req = flip WaiTest.setRawPathInfo path WaiTest.defaultRequest {
          Wai.requestMethod  = HT.methodPost
      }

migrate :: P.ConnectionPool -> IO ()
migrate p = liftIO $ DB.runDB p $ P.runMigration DB.migrateAll

getApp :: P.ConnectionPool -> IO Wai.Application
getApp p = liftIO $ Scotty.scottyApp $ App.app p

getBody :: WaiTest.SResponse -> BS.ByteString
getBody res = BS.concat . LBS.toChunks $ WaiTest.simpleBody res

should :: Show a => (a -> a -> Bool) -> a -> a -> Expectation
should be actual expected = actual `be` expected `shouldBe` True

shouldContains :: BS.ByteString -> BS.ByteString -> Expectation
shouldContains subject matcher = should BS.isInfixOf matcher subject
