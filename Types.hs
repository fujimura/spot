{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
module Types
    (
      SpotResponse (SpotResponse)
    , SpotsResponse (SpotsResponse)
    , toSpotResponse
    , toSpotsResponse
    ) where

import qualified Data.Aeson   as AE
import           DB
import           GHC.Generics (Generic)

data SpotResponse = SpotResponse { spot :: Spot }
                  deriving (Show, Generic)

data SpotsResponse = SpotsResponse { spots :: [SpotResponse] }
                  deriving (Show, Generic)

instance AE.FromJSON SpotResponse
instance AE.ToJSON SpotResponse

instance AE.FromJSON SpotsResponse
instance AE.ToJSON SpotsResponse

toSpotResponse :: Spot -> SpotResponse
toSpotResponse = SpotResponse

toSpotsResponse :: [Spot] -> SpotsResponse
toSpotsResponse xs = SpotsResponse $ map SpotResponse xs
