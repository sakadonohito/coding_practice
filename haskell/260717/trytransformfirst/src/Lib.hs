module Lib (tryTransformFirst) where

tryTransformFirst ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  Either String (Maybe (Int, Int), [Int])
tryTransformFirst _ _ [] = Right (Nothing, [])
tryTransformFirst predicate transform (x : xs)
  | predicate x =
      case transform x of
        Left err -> Left err
        Right transformed -> Right (Just (x, 0), transformed : xs)
  | otherwise =
      case tryTransformFirst predicate transform xs of
        Left err -> Left err
        Right (found, transformedXs) ->
          case found of
            Nothing ->
              Right (Nothing, x : transformedXs)
            Just (value, index) ->
              Right (Just (value, index + 1), x : transformedXs)
