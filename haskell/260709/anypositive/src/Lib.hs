module Lib (anyPositive) where

anyPositive :: [Int] -> Bool
anyPositive [] = False
anyPositive (x : xs)
  | x > 0 = True
  | otherwise = anyPositive xs
