{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}
module App
    ( app
    ) where

import Control.Applicative ((<$>))
import Control.Monad.Trans
import Data.Text ()
import qualified Data.ByteString         as BS
import Data.Text.Lazy.Encoding (decodeUtf8)
import Data.Data
import Text.Hastache
import Text.Hastache.Context
import Web.Scotty hiding (body)
import qualified Database.Persist.Sqlite as P
import DB

data Info = Info {
    name    :: String
  , unread  :: Int
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
    -- #TODO Get environment from command line argument like "-e production"
    let db = runDB p

    get "/" $
        mustache "views/home.mustache" $ Info "Haskell" 100

    get "/spots" $ withRescue $ do
        spots <- db $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json spots

    put "/spots/:id" $ withRescue $ do
        spotId' <- param "id"
        spotData <- jsonData :: ActionM Spot
        -- TODO use lambda
        let spotId = (read spotId' :: SpotId)
        spot <- db $ P.updateGet spotId $ toUpdateQuery spotData
        json spot

    post "/spots" $ withRescue $ do
        spotData <- jsonData :: ActionM Spot
        spotId <- db $ P.insert spotData
        spot <- db $ P.get spotId
        json spot

    delete "/spots/:id" $ withRescue $ do
        spotId' <- param "id"
        let spotId = (read spotId' :: SpotId)
        _ <- db $ P.delete spotId
        --FIXME What is the best return value of delete request?
        json ("Deleted" :: BS.ByteString)
