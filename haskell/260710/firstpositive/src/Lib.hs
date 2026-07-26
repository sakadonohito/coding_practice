module Lib (firstPositive) where

firstPositive :: [Int] -> Maybe Int
firstPositive [] = Nothing
firstPositive (x : xs)
  | x > 0 = Just x
  | otherwise = firstPositive xs
