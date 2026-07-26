module Lib
    ( filterPositive,
      filterPositiveGuard
    ) where

filterPositive :: [Int] -> [Int]
filterPositive [] = []
filterPositive (x : xs) =
  if x > 0
    then x : filterPositive xs
    else filterPositive xs

filterPositiveGuard :: [Int] -> [Int]
filterPositiveGuard [] = []
filterPositiveGuard (x : xs)
  | x > 0     = x : filterPositiveGuard xs
  | otherwise = filterPositiveGuard xs
