{-# LANGUAGE OverloadedStrings #-}

import Database.Persist.Sqlite
import DB

main :: IO ()
main = do
    runDB' "development.sqlite" $ runMigration migrateAll
    runDB' "test.sqlite" $ runMigration migrateAll
