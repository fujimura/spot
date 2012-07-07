{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

import Test.Hspec.Monadic
import qualified Spec.Spot

main = hspec $ do
  Spec.Spot.spec
