{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

import Network.Wai.Middleware.RequestLogger
import Network.Wai.Middleware.Static
import Web.Scotty hiding (body)
import qualified Data.Text               as T
import qualified Database.Persist.Sqlite as P
import qualified Config
import qualified Option
import qualified App

main :: IO ()
main = do
    port        <- Option.port
    environment <- Option.environment
    database    <- Config.get (T.unpack "config/database.yml") environment "database"
    pool        <- P.createSqlitePool database 3

    scotty port $ do
      middleware logStdoutDev
      middleware $ staticPolicy $ addBase "static"

      App.app pool
