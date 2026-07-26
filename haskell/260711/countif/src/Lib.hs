module Lib (countIf) where

countIf :: (Int -> Bool) -> [Int] -> Int
countIf _ [] = 0
countIf predicate (x : xs)
  | predicate x = 1 + countIf predicate xs
  | otherwise = countIf predicate xs
