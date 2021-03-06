{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE IncoherentInstances #-}
{-# LANGUAGE DeriveGeneric #-}

module Test.QuickFuzz.Gen.Image.Gif where

import Data.Default

import qualified Data.Binary
import Codec.Picture.Gif
import Codec.Picture.Types
import Codec.Picture.ColorQuant

import Test.QuickCheck
import Control.Monad
import Control.DeepSeq

import Control.Monad.Trans
import Control.Monad.Trans.State
import Data.List
import Data.Monoid 

import Test.QuickFuzz.Derive.Arbitrary
import Test.QuickFuzz.Derive.NFData

import Test.QuickFuzz.Derive.Show
import Test.QuickFuzz.Gen.FormatInfo
import Test.QuickFuzz.Gen.Base.ByteString
import Test.QuickFuzz.Gen.Base.String
import Test.QuickFuzz.Gen.Base.Image

import qualified Data.ByteString.Lazy as L

devShow ''GifFile
devArbitrary ''GifFile
devNFData ''GifFile

gifencode :: GifFile -> L.ByteString
gifencode = Data.Binary.encode

gifInfo :: FormatInfo GifFile NoActions
gifInfo = def 
    { encode = gifencode
    , random = arbitrary
    , value = show
    , ext = "gif" 
    } 
