{-# LANGUAGE OverloadedStrings #-}
module Helper
    ( invalidJSON
    , withRescue
    , toKey
    ) where

import qualified Data.Aeson              as AE
import           Data.Monoid             (mconcat)
import           Data.Text               (Text)
import qualified Database.Persist.Sqlite as P
import qualified Network.HTTP.Types      as HT
import           Web.PathPieces
import           Web.Scotty

withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

invalidJSON :: ActionM ()
invalidJSON = do
  b <- body
  status HT.status400
  json $ AE.object ["message" AE..= mconcat ["Invalid JSON format: ", b]]

toKey :: String -> P.Key backend entity
toKey x = P.Key $ P.toPersistValue $ toPathPiece x
