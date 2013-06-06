{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

module AppSpec ( spec ) where

import qualified Database.Persist.Sqlite as P
import           SpecHelper

spec :: P.ConnectionPool -> Spec
spec p = do
  describe "GET /" $
    it "should contains 'haskell' in response body" $ do
      app <- getApp p
      res <- app `get` ""
      getBody res `shouldContains` "Haskell"
