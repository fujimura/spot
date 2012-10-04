{-# LANGUAGE OverloadedStrings #-}
module Helper
    ( withRescue
    , toKey
    ) where

import           Web.Scotty              hiding (body)
import           Data.Text (Text)
import qualified Database.Persist.Sqlite  as P
import           Web.PathPieces

withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

toKey :: String -> P.Key backend entity
toKey x = P.Key $ P.toPersistValue $ toPathPiece x
