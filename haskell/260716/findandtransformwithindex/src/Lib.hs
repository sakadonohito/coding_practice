module Lib (findAndTransformWithIndex) where

findAndTransformWithIndex ::
  (Int -> Bool) ->
  (Int -> Int) ->
  [Int] ->
  (Maybe (Int, Int), [Int])
findAndTransformWithIndex _ _ [] = (Nothing, [])
findAndTransformWithIndex predicate transform (x : xs)
  | predicate x = (Just (x, 0), transform x : xs)
  | otherwise =
      let (found, transformedXs) = findAndTransformWithIndex predicate transform xs
       in case found of
            Nothing ->
              (Nothing, x : transformedXs)
            Just (value, index) ->
              (Just (value, index + 1), x : transformedXs)
