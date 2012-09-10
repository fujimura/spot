{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

import Test.Hspec
import qualified Spec.Spot
import Spec.SpecHelper (migrate)

main :: IO ()
main = do
  migrate
  hspec $ do
    Spec.Spot.spec
