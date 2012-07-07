{-# LANGUAGE QuasiQuotes, TemplateHaskell, TypeSynonymInstances, FlexibleInstances, TypeFamilies, OverloadedStrings #-}
{-# LANGUAGE GADTs, FlexibleContexts #-}
module DB where

import Control.Monad.Trans
import Control.Applicative ((<$>), (<*>), empty)
import Data.Aeson ((.:), (.=), FromJSON, ToJSON)
import qualified Data.Aeson as A
import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persist|
Spot
    lat Double
    lng Double
    body String
    deriving Show
|]

instance FromJSON Spot where
  parseJSON (A.Object v) = Spot <$>
                         v .: "lat" <*>
                         v .: "lng" <*>
                         v .: "body"
  parseJSON _          = empty

instance ToJSON Spot where
  toJSON (Spot lat lng body ) = A.object [ "lat" .= lat,
                                           "lng" .= lng,
                                           "body".= body ]

runDB action = runDB' "development.sqlite" action

runDB' name action = liftIO $ do
    withSqliteConn name $ \c -> do
    runSqlConn action c
