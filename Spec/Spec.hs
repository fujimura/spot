{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

import qualified Database.Persist.Sqlite as P
import           Spec.Helper             (migrate)
import qualified Spec.Spot
import           Test.Hspec

main :: IO ()
main = do
  -- TODO DRY up with Main.hs
  pool <- P.createSqlitePool ":memory:" 3
  migrate pool
  hspec $ do
    Spec.Spot.spec pool
