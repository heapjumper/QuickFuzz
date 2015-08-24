{-# LANGUAGE TemplateHaskell, FlexibleInstances#-}

module Png where

import Test.QuickCheck
import Check

import Control.Monad.Zip
import Control.Exception
import Data.Binary( Binary(..), encode )

import Codec.Picture.Types
import Codec.Picture.Png
import Codec.Picture.Png.Type
import Codec.Picture.Png.Export
import Codec.Picture.Metadata


import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString as B

import Data.DeriveTH
import Data.Word(Word8, Word16, Word32)
import Data.Int( Int16, Int8 )

import DeriveArbitrary

import GHC.Types
import GHC.Word

import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as VU
import qualified Data.Vector.Storable as VS

import System.Process
import System.Exit


instance Arbitrary a => Arbitrary (V.Vector a) where
   arbitrary = do 
     l <- listOf arbitrary
     return $ V.fromList l

instance (VU.Unbox a, Arbitrary a) => Arbitrary (VU.Vector a) where
   arbitrary = do 
     l <- listOf arbitrary
     return $ VU.fromList l

instance (VS.Storable a, Arbitrary a) => Arbitrary (VS.Vector a) where
   arbitrary = do 
     l <- listOf arbitrary
     return $ VS.fromList l


instance Arbitrary B.ByteString where
   arbitrary = do 
     l <- listOf (arbitrary :: Gen Word8)
     return $ B.pack l

instance Arbitrary L.ByteString where
   arbitrary = do 
     l <- listOf (arbitrary :: Gen Word8)
     return $ L.pack l
{-
instance Arbitrary (Metadatas) where
  arbitrary = do
      w <- (arbitrary :: Gen Word)
      s <- (arbitrary :: Gen String)
      d <- (arbitrary :: Gen Double) 
      sf <- (arbitrary :: Gen SourceFormat)
      return $ Metadatas { getMetadatas = [ Format :=> sf, Gamma :=> d,  DpiX :=> w, DpiY :=> w, Width :=> w, Height :=> w, Title :=> s] }
-}
instance Arbitrary (Image PixelYCbCr8) where
   arbitrary = do
       l <- listOf (arbitrary :: Gen (PixelBaseComponent PixelYCbCr8))
       w <- (arbitrary :: Gen Int)
       h <- (arbitrary :: Gen Int)
       return $ Image { imageWidth = w, imageHeight = h, imageData = VS.fromList [1] }

instance Show (Image PixelYCbCr8) where
   show x = ""


type MPngImage = (Metadatas, Palette, Image Pixel8)
encodePngImage (a,b,c,d) = encodePalettedPngWithMetadata a b c

$(deriveArbitraryRec ''MPngImage)

mencode :: JpgImage -> L.ByteString
mencode = encodePngImage

main = quickCheckWith stdArgs { maxSuccess = 120, maxSize = 50 } (absprop "buggy_qc.png" "/usr/bin/pnginfo" ["buggy_qc.png"] mencode)