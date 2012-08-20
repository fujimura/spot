{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

import Test.Hspec
import qualified Spot

main :: IO ()
main = hspec $ do
  Spot.spec
