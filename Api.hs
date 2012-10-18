{-# LANGUAGE OverloadedStrings #-}
module Api
    ( app
    ) where

import           Control.Applicative     ((<$>))
import           Control.Monad           (when)
import qualified Data.Aeson              as AE
import           Data.Maybe              (isNothing)
import           Data.Monoid             (mconcat)
import           Data.Text               ()
import qualified Database.Persist.Sqlite as P
import           DB
import           Helper
import qualified Network.HTTP.Types      as HT
import           Web.Scotty

app :: P.ConnectionPool -> ScottyM ()
app p = do
    let db = runDB p

    get "/spots" $ withRescue $ do
        resources <- db $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json resources

    get "/spots/:id" $ do
        key      <- toKey <$> param "id"
        resource <- db $ P.get (key :: SpotId)
        case resource of
            Just r  -> json $ r
            Nothing -> status HT.status404

    put "/spots/:id" $ withRescue $ do
        key      <- toKey <$> param "id"
        value    <- jsonData
        db $ P.update key $ toUpdateQuery (value :: Spot)
        resource <- db $ P.get (key :: SpotId)
        case resource of
            Just r  -> json $ r
            Nothing -> status HT.status404

    post "/spots" $ withRescue $ do
        value    <- AE.decode <$> body
        case value of
            Just v -> do
              key      <- db $ P.insert (v :: Spot)
              resource <- db $ P.get key
              json resource
            Nothing -> do
              status HT.status400
              invalidJSON <- body
              json $ AE.object ["message" AE..= mconcat ["Invalid JSON format: ", invalidJSON]]

    delete "/spots/:id" $ withRescue $ do
        key <- toKey <$> param "id"
        resource <- db $ P.get (key :: SpotId)
        when (isNothing resource) (status HT.status404)
        _   <- db $ P.delete (key :: SpotId)
        json True
