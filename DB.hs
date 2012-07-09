{-# LANGUAGE QuasiQuotes, TemplateHaskell, TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances, TypeFamilies, OverloadedStrings #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
module DB where

import Control.Monad.Trans
import Data.Text (Text)
import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persist|
Spot json
    lat Double
    lng Double
    body String
    deriving Show
|]

runDB :: MonadIO m => SqlPersist IO a -> m a
runDB = runDB' "development.sqlite"

runDB' :: MonadIO m => Text -> SqlPersist IO a -> m a
runDB' name action = liftIO $ withSqliteConn name $ runSqlConn action
