{-# LANGUAGE OverloadedStrings, DeriveDataTypeable, TypeSynonymInstances, FlexibleInstances#-}

import Control.Applicative ((<$>), (<*>), empty)
import Control.Monad.Trans
import Data.Text.Lazy.Encoding (decodeUtf8)
import Data.Aeson ((.:), (.=))
import Data.Data
import Data.Generics
import qualified Data.Aeson as A
import Text.Hastache
import Text.Hastache.Context
import Network.Wai
import Network.Wai.Middleware.RequestLogger -- install wai-extra if you don't have this
import Network.Wai.Middleware.Static
import Web.Scotty
import qualified Database.Persist.Sqlite as P
import DB

data Info = Info {
    name    :: String,
    unread  :: Int
    } deriving (Data, Typeable)

mustache :: (Data a, Typeable a) => FilePath -> a -> ActionM ()
mustache path context = do
  body <- liftIO $ decodeUtf8 <$> hastacheFile defaultConfig path (mkGenericContext context)
  html body

withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue (\msg -> text msg)

main :: IO ()
main = scotty 3000 $ do
    -- Add any WAI middleware, they are run top-down.
    middleware logStdoutDev
    middleware $ staticPolicy $ addBase "static"

    get "/" $ do
        mustache "views/home.mustache" $ Info "Haskell" 100

    get "/spots" $ withRescue $ do
        spots <- runDB $
          map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
        json spots

    post "/spots" $ withRescue $ do
        spotData <- jsonData :: ActionM Spot
        spotId <- runDB $ P.insert spotData
        spot <- runDB $ P.get spotId
        json spot
