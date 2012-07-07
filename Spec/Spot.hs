{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
module Spec.Spot ( spec ) where

import Control.Monad.Trans
import Control.Exception(bracket_)
import Test.Hspec.Monadic
import Test.Hspec.HUnit ()
import Test.HUnit ((@?=), assertFailure, Assertion)
import qualified Database.Persist.Sqlite as P
import DB

spec = do
  describe "Spot" $ do
    let withData = bracket_ setup teardown
             where
               setup =
                 runDB' "test.sqlite" $ P.insert $ Spot 1.2 1.3 "ABC"
               teardown =
                 runDB' "test.sqlite" $ P.deleteWhere ([] :: [P.Filter Spot])
    it "should return summary of all world's revenue" $
      withData $ do
        True @?= True
    it "should " $ pending "HOO"
