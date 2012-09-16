{-# LANGUAGE OverloadedStrings #-}

module Config
    ( get
    ) where

import Control.Applicative
import Data.Text
import Data.Yaml
import Data.Maybe (fromMaybe)
import qualified Data.HashMap.Strict as M

{-
  most code is taken from Yesod's configuration handling.
  see original in:
    https://github.com/yesodweb/yesod/blob/master/yesod-default/Yesod/Default/Config.hs
-}


get :: FilePath -> Text -> Text -> IO Text
get path env configName = do
    file <- decodeFile path
    allConfigs <- maybe (fail "Invalid YAML file") return file
    configs <- getObject env allConfigs

    lookupScalar configName configs

    where
        lookupScalar k m =
            case M.lookup k m of
                Just (String t) -> return t
                Just _          -> fail $ "Invalid value for: " ++ show k
                Nothing         -> fail $ "Not found: " ++ show k

        getObject env v = do
          envs <- fromObject v
          maybe
              (error $ "Could not find environment: " ++ show env)
              return $ fromObject =<< M.lookup env envs

        fromObject m =
          case m of
              Object o -> return o
              _        -> fail "Invalid JSON format"
