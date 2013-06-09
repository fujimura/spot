{-# LANGUAGE DeriveDataTypeable   #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TypeSynonymInstances #-}

import qualified App
import qualified Api
import qualified Config
import qualified Migrate
import qualified Data.Text                            as T
import qualified Database.Persist.Sqlite              as P
import           Network.Wai.Middleware.RequestLogger
import           Network.Wai.Middleware.Static
import qualified Option
import           Web.Scotty                           hiding (body)

main :: IO ()
main = do
    port        <- Option.port
    environment <- Option.environment
    database    <- Config.get (T.unpack "config/database.yml") environment "database"
    pool        <- P.createSqlitePool database 3

    scotty port $ do
      middleware logStdoutDev
      middleware $ staticPolicy $ addBase "static"

      App.app
      Api.app pool
