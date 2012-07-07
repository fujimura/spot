{-# LANGUAGE OverloadedStrings #-}
import Control.Monad.Trans
import Database.Persist.Sqlite
import DB

main = do
    runDB' "development.sqlite" $ runMigration migrateAll
    runDB' "test.sqlite" $ runMigration migrateAll
