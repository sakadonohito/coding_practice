module Lib (partitionFirst) where

partitionFirst :: (Int -> Bool) -> [Int] -> ([Int], [Int])
partitionFirst _ [] = ([], [])
partitionFirst predicate (x : xs)
  | predicate x = ([], x : xs)
  | otherwise =
      let (before, after) = partitionFirst predicate xs
       in (x : before, after)
