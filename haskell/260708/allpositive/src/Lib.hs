module Lib ( allPositive ) where

allPositive :: [Int] -> Bool
allPositive [] = True
allPositive (x : xs)
  | x > 0 = allPositive xs
  | otherwise = False
