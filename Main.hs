{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

import qualified Data.Text as T
import Network.Wai.Middleware.RequestLogger -- install wai-extra if you don't have this
import Network.Wai.Middleware.Static
import qualified Database.Persist.Sqlite as P
import Web.Scotty hiding (body)
import Config
import qualified Option
import App

main :: IO ()
main = do
    port        <- Option.port
    environment <- Option.environment
    database    <- getConfig (T.unpack "config/database.yml") environment "database"
    pool        <- P.createSqlitePool database 3

    scotty port $ do
      -- Add any WAI middleware, they are run top-down.
      middleware logStdoutDev
      middleware $ staticPolicy $ addBase "static"

      app pool
