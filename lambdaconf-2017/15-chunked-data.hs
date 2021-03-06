#!/usr/bin/env stack
{-
  stack --resolver lts-8.12 exec
    --package conduit-combinators
    --package unordered-containers
    --
    ghc --make -O2 -Wall -Wall -fwarn-tabs -fno-warn-type-defaults
-}
import Conduit
import Data.HashMap.Strict as HM
import GHC.Word (Word8)
import Data.List
import Data.Ord

word8ToChar :: Word8 -> Char
word8ToChar = toEnum . fromEnum

sinkHistogram :: Monad m => ConduitM Word8 o m (HM.HashMap Char Int)
sinkHistogram = foldlC go HM.empty
  where
    go map1 word = HM.insertWith (+) (word8ToChar word) 1 map1

main :: IO ()
main = do
  histogram <- runConduitRes $ sourceFile "big.txt" .| concatC .| sinkHistogram
  let sorted = sortOn (Down . snd) (toList histogram)
  mapM_ print $ take 10 $ sorted
