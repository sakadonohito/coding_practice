module Lib (updateFirst) where

updateFirst :: (Int -> Bool) -> (Int -> Int) -> [Int] -> [Int]
updateFirst _ _ [] = []
updateFirst predicate transform (x : xs)
  | predicate x = transform x : xs
  | otherwise = x : updateFirst predicate transform xs
