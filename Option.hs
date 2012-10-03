{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}

module Option
    ( port
    , environment
    ) where

import           Control.Applicative
import qualified Data.Text              as T
import           System.Console.CmdArgs

data Options = Options { port'        :: String
                       , environment' :: String }
              deriving (Show, Data, Typeable)

options = Options { port' = "3000"
                  , environment' = "development" }

getOption :: (Options -> a) -> IO a
getOption f = f <$> cmdArgs options

port :: IO Int
port = do
    v <- getOption port'
    return (read v :: Int)

environment :: IO T.Text
environment = T.pack <$> getOption environment'
