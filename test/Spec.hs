{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}

import qualified Database.Persist.Sqlite as P
import           SpecHelper             (migrate)
import qualified AppSpec
import qualified ApiSpec
import           Test.Hspec

main :: IO ()
main = do
  pool <- P.createSqlitePool ":memory:" 3
  migrate pool
  hspec $ do
    AppSpec.spec pool
    ApiSpec.spec pool
