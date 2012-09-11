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

runDB :: MonadIO m => ConnectionPool -> SqlPersist IO a -> m a
runDB p action = liftIO $ runSqlPool action p
