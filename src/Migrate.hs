{-# LANGUAGE OverloadedStrings #-}

module Migrate
    ( run
    ) where

import           Control.Exception
import           Control.Monad
import qualified Data.Text               as T
import           Database.Persist.Sqlite
import           System.Directory        (doesDirectoryExist)

import qualified Config
import qualified Database.Persist.Sqlite as P
import           DB

run :: IO ()
run = do
    d <- doesDirectoryExist "db"
    unless d $ fail "Directory ./db does not exist. Retry after creating ./db"

    development <- Config.get (T.unpack "config/database.yml") "development" "database"
    pool <- P.createSqlitePool development 3
    runDB pool $ runMigration migrateAll
