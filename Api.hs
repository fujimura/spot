{-# LANGUAGE OverloadedStrings #-}
module Api
    ( app
    ) where

import           Control.Applicative     ((<$>))
import           Control.Monad           (when)
import           Data.Maybe              (isNothing)
import           Data.Text               ()
import qualified Database.Persist.Sqlite as P
import           DB
import           Helper
import qualified Network.HTTP.Types      as HT
import           Types
import           Web.Scotty

app :: P.ConnectionPool -> ScottyM ()
app p = do
    let db = runDB p

    get "/spots" $ withRescue $ do
        resources <- db $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json $ toSpotsResponse resources

    get "/spots/:id" $ do
        key      <- toKey <$> param "id"
        resource <- db $ P.get (key :: SpotId)
        case resource of
            Just r  -> json $ SpotResponse r
            Nothing -> status HT.status404

    put "/spots/:id" $ withRescue $ do
        key   <- toKey <$> param "id"
        value <- fromSpotResponse <$> jsonData
        db $ P.update key $ toUpdateQuery value
        resource <- db $ P.get (key :: SpotId)
        case resource of
            Just r  -> json $ SpotResponse r
            Nothing -> status HT.status404

    post "/spots" $ withRescue $ do
        value    <- fromSpotResponse <$> jsonData
        key      <- db $ P.insert value
        resource <- db $ P.get key
        json resource

    delete "/spots/:id" $ withRescue $ do
        key <- toKey <$> param "id"
        resource <- db $ P.get (key :: SpotId)
        when (isNothing resource) (status HT.status404)
        _   <- db $ P.delete (key :: SpotId)
        json True
