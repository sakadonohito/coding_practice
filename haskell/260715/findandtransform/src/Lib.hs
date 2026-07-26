module Lib (findAndTransform) where

findAndTransform :: (Int -> Bool) -> (Int -> Int) -> [Int] -> (Maybe Int, [Int])
findAndTransform _ _ [] = (Nothing, [])
findAndTransform predicate transform (x : xs)
  | predicate x = (Just x, transform x : xs)
  | otherwise =
      let (before, after) = findAndTransform predicate transform xs
       in (before, x : after)
