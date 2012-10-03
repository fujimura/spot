{-# LANGUAGE DeriveDataTypeable   #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TypeSynonymInstances #-}
module App
    ( app
    ) where

import           Control.Applicative     ((<$>))
import           Control.Monad.Trans
import qualified Data.ByteString         as BS
import           Data.Data
import           Data.Text ()
import           Data.Text.Lazy.Encoding (decodeUtf8)
import qualified Database.Persist.Sqlite as P
import           DB
import           Text.Hastache
import           Text.Hastache.Context
import           Web.Scotty              hiding (body)

data Info = Info {
    name   :: String
  , unread :: Int
  } deriving (Data, Typeable)

mustache :: (Data a, Typeable a) => FilePath -> a -> ActionM ()
mustache path context = do
  body <- liftIO $ decodeUtf8 <$> hastacheFile defaultConfig path (mkGenericContext context)
  html body

withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

app :: P.ConnectionPool -> ScottyM ()
app p = do
    let db = runDB p

    get "/" $
        mustache "views/home.mustache" $ Info "Haskell" 100

    get "/spots" $ withRescue $ do
        resources <- db $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json resources

    get "/spots/:id" $ withRescue $ do
        key      <- param "id"
        resource <- db $ P.get (read key :: SpotId)
        json resource

    put "/spots/:id" $ withRescue $ do
        key      <- param "id"
        value    <- jsonData :: ActionM Spot
        resource <- db $ P.updateGet (read key :: SpotId) $ toUpdateQuery value
        json resource

    post "/spots" $ withRescue $ do
        value    <- jsonData :: ActionM Spot
        key      <- db $ P.insert value
        resource <- db $ P.get key
        json resource

    delete "/spots/:id" $ withRescue $ do
        key <- param "id"
        _   <- db $ P.delete (read key :: SpotId)
        json True
