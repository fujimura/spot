{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Control.Exception
import qualified Data.Text as T
import System.Directory(doesDirectoryExist)
import Database.Persist.Sqlite

import Config
import DB

main :: IO ()
main = do
    d <- doesDirectoryExist "db"
    unless d $ fail "Directory ./db does not exist. Retry after creating ./db"

    development <- getConfig (T.unpack "config/database.yml") "development" "database"
    test        <- getConfig (T.unpack "config/database.yml") "test" "database"
    runDB' development $ runMigration migrateAll
    runDB' test $ runMigration migrateAll
