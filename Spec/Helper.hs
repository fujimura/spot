{-# LANGUAGE OverloadedStrings #-}

module Spec.Helper
  (
    module X
  , bracket_
  , get
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
import qualified Codec.Binary.UTF8.String as CBUS
import qualified Network.Wai              as Wai
import qualified Network.Wai.Test         as WaiTest
import qualified Network.Socket.Internal  as Sock
import qualified Network.HTTP.Types       as HT
import qualified Database.Persist.Sqlite  as P
import qualified Web.Scotty               as Scotty

import qualified DB
import qualified App

get app path =
  WaiTest.runSession (WaiTest.request req) app
      where req = Wai.Request {
          Wai.requestMethod  = HT.methodGet
        , Wai.httpVersion    = HT.http11
        , Wai.rawPathInfo    = path
        , Wai.rawQueryString = ""
        , Wai.serverName     = "localhost"
        , Wai.serverPort     = 80
        , Wai.requestHeaders = []
        , Wai.isSecure       = False
        , Wai.remoteHost     = Sock.SockAddrInet (Sock.PortNum 80) 100
        , Wai.pathInfo       = filter (/="") $ T.split (== '/') $ TE.decodeUtf8 path
        , Wai.queryString    = []
        , Wai.requestBody    = mempty
        , Wai.vault          = mempty
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
