{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

import qualified Database.Persist.Sqlite as P
import           Spec.Helper             (migrate)
import qualified Spec.App
import qualified Spec.Api
import           Test.Hspec

main :: IO ()
main = do
  pool <- P.createSqlitePool ":memory:" 3
  migrate pool
  hspec $ do
    Spec.App.spec pool
    Spec.Api.spec pool
