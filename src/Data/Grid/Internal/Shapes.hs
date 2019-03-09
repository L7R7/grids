{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -ddump-deriv #-}

module Data.Grid.Internal.Shapes (neighbouringWindow, Neighbours(..), orthNeighbours, NZipper) where

import GHC.TypeNats
import Data.Grid.Internal.Grid
import Data.Bifunctor
import Data.Bifunctor.Join
import Data.Bifunctor.Biff
import Data.Functor.Identity
import Data.Functor.Compose
import Data.Grid.Internal.Convolution
import Data.Grid.Internal.Coord
import Data.Singletons.Prelude
import Data.Singletons.Prelude.List
import Data.Coerce
import Data.Function
import Data.Functor.Rep
import Control.Lens
import Data.Proxy

--------------------------------------------------------------------------------
-- Windowing Shapes
--------------------------------------------------------------------------------
newtype Neighbours (window :: [Nat]) a = Neighbours (a, (Grid window (Maybe a)))
    deriving (Functor, Applicative, Foldable) via Join (Biff (,) Identity (Compose (Grid window) Maybe))
    deriving Traversable

-- | Given a coordinate generate a grid of size 'window' filled with
-- coordinates surrounding the given coord. Mostly used internally
neighbouringWindow :: forall window dims.
                   (Neighboring window, Dimensions window)
                   => Coord dims
                   -> Neighbours window (Coord dims)
neighbouringWindow focus = coerce (focus, (window @window @dims focus & imapRep wrapMaybe))
  where
    wrapMaybe (coerceCoordDims -> c) a
      | c == focus = Nothing
      | otherwise = Just a
