{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

import Test.Hspec
import qualified Spec.Spot

main :: IO ()
main = hspec $ do
  Spec.Spot.spec
