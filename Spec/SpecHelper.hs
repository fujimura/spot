{-# LANGUAGE OverloadedStrings #-}

module Spec.SpecHelper
  (
    module X
  , bracket_
  , get
  , getApp
  , getBody
  , initReq
  , runTestDB
  , testDB
  ) where

import Control.Monad.Trans as X
import Control.Applicative as X
import Test.Hspec          as X

import Control.Exception (bracket_)
import Data.Text
import Data.Monoid (mempty)

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

initReq :: Wai.Request
initReq = Wai.Request {
    Wai.requestMethod  = HT.methodGet
  , Wai.httpVersion    = HT.http11
  , Wai.rawPathInfo    = BS.pack . CBUS.encode $ ""
  , Wai.rawQueryString = BS.pack . CBUS.encode $ ""
  , Wai.serverName     = BS.pack . CBUS.encode $ "localhost"
  , Wai.serverPort     = 80
  , Wai.requestHeaders = []
  , Wai.isSecure       = False
  , Wai.remoteHost     = Sock.SockAddrInet (Sock.PortNum 80) 100
  , Wai.pathInfo       = []
  , Wai.queryString    = []
  , Wai.requestBody    = mempty
  , Wai.vault          = mempty
}

get app path =
  WaiTest.runSession (WaiTest.request req) app
      -- TODO DRY up
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
				, Wai.pathInfo       = ["spots"]
				, Wai.queryString    = []
				, Wai.requestBody    = mempty
				, Wai.vault          = mempty
			}

testDB :: Text
testDB = "db/test.sqlite3"

runTestDB :: P.SqlPersist IO a -> IO a
runTestDB = DB.runDB' testDB

getApp :: IO Wai.Application
getApp = liftIO $ do
  Scotty.scottyApp $ App.app testDB

getBody :: WaiTest.SResponse -> BS.ByteString
getBody res = BS.concat . LBS.toChunks $ WaiTest.simpleBody res
