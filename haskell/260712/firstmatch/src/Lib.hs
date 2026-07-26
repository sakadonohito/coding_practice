module Lib (firstMatch) where

firstMatch :: (Int -> Bool) -> [Int] -> Maybe Int
firstMatch _ [] = Nothing
firstMatch predicate (x : xs)
  | predicate x = Just x
  | otherwise = firstMatch predicate xs
