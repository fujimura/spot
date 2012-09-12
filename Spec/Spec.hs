{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}

import qualified Database.Persist.Sqlite as P
import Test.Hspec
import qualified Spec.Spot
import Spec.Helper (migrate)

main :: IO ()
main = do
  -- TODO DRY up with Main.hs
  pool <- P.createSqlitePool ":memory:" 3
  migrate pool
  hspec $ do
    Spec.Spot.spec pool
