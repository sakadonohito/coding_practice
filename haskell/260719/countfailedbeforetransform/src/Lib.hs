module Lib (countFailedBeforeTransform) where

countFailedBeforeTransform ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  (Int, Maybe ((Int, Int), [Int]))
countFailedBeforeTransform _ _ [] = (0, Nothing)
countFailedBeforeTransform predicate transform (x : xs)
  | predicate x =
      case transform x of
        Left _ ->
          case countFailedBeforeTransform predicate transform xs of
            -- 後続も変換成功していない
            (failed, Nothing) ->
              (failed + 1, Nothing)
            -- 後続で処理成功
            (failed, Just ((value, index), transformedXs)) ->
              (failed + 1, Just ((value, index + 1), x : transformedXs))
        Right transformed ->
          (0, Just ((x, 0), transformed : xs))
  | otherwise =
      case countFailedBeforeTransform predicate transform xs of
        -- 後続で条件は満たしているが変換成功していない or 後続もずっと条件を満たさない場合
        (failed, Nothing) ->
          (failed, Nothing)
        -- 後続は条件を満たしている
        (failed, Just ((value, index), transformedXs)) ->
          (failed, Just ((value, index + 1), x : transformedXs))
