module Lib ( findFirstTransformable ) where

findFirstTransformable ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  Maybe ((Int, Int), [Int])
findFirstTransformable _ _ [] = Nothing
findFirstTransformable predicate transform (x : xs )
  | predicate x =
      case transform x of
        Left _ ->
          case findFirstTransformable predicate transform xs of
            Nothing ->
              Nothing
            Just ((found,index), transformedXs) ->
              Just ((found, index + 1), x : transformedXs)
        Right transformed -> Just ((x, 0), transformed : xs)
  | otherwise =
      case findFirstTransformable predicate transform xs of
        Nothing ->
          Nothing
        Just ((found,index), transformedXs) ->
          Just ((found, index + 1), x : transformedXs)
