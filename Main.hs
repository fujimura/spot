{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

import qualified Data.Text as T
import Network.Wai.Middleware.RequestLogger -- install wai-extra if you don't have this
import Network.Wai.Middleware.Static
import Web.Scotty hiding (body)
import Config
import App

main :: IO ()
main = do
    db <- getConfig (T.unpack "config/database.yml") "development" "database"

    scotty 3000 $ do
      -- Add any WAI middleware, they are run top-down.
      middleware logStdoutDev
      middleware $ staticPolicy $ addBase "static"

      app db
