{-# LANGUAGE OverloadedStrings    #-}
module Api
    ( app
    ) where

import           Control.Applicative     ((<$>))
import           Data.Text ()
import qualified Database.Persist.Sqlite as P
import           DB
import           Web.Scotty              hiding (body)

withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

app :: P.ConnectionPool -> ScottyM ()
app p = do
    let db = runDB p

    get "/spots" $ withRescue $ do
        resources <- db $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json resources

    get "/spots/:id" $ withRescue $ do
        key      <- param "id"
        resource <- db $ P.get (read key :: SpotId)
        json resource

    put "/spots/:id" $ withRescue $ do
        key      <- param "id"
        value    <- jsonData
        resource <- db $ P.updateGet (read key :: SpotId) $ toUpdateQuery (value :: Spot)
        json resource

    post "/spots" $ withRescue $ do
        value    <- jsonData
        key      <- db $ P.insert (value :: Spot)
        resource <- db $ P.get key
        json resource

    delete "/spots/:id" $ withRescue $ do
        key <- param "id"
        _   <- db $ P.delete (read key :: SpotId)
        json True
