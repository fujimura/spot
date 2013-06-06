{-# LANGUAGE DeriveDataTypeable   #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TypeSynonymInstances #-}
module App
    ( app
    ) where

import           Control.Applicative     ((<$>))
import           Control.Monad.Trans
import           Data.Data
import           Data.Text ()
import           Data.Text.Lazy.Encoding (decodeUtf8)
import           Text.Hastache
import           Text.Hastache.Context
import           Web.Scotty              hiding (body)

data Info = Info {
    name   :: String
  , unread :: Int
  } deriving (Data, Typeable)

mustache :: (Data a, Typeable a) => FilePath -> a -> ActionM ()
mustache path context = do
  body <- liftIO $ decodeUtf8 <$> hastacheFile defaultConfig path (mkGenericContext context)
  html body

app :: ScottyM ()
app = do

    get "/" $
        mustache "views/home.mustache" $ Info "Haskell" 100
