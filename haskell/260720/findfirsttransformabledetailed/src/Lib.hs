module Lib
  ( TransformResult (..),
    findFirstTransformableDetailed,
  )
where

data TransformResult
  = NoTransform [String]
  | Transformed Int Int [Int] [String]
  deriving (Eq, Show)

findFirstTransformableDetailed ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  TransformResult
findFirstTransformableDetailed _ _ [] = NoTransform []
-- findFirstTransformableDetailed _ _ (x : xs) = undefined
findFirstTransformableDetailed predicate transform (x : xs)
  | predicate x =
      -- 条件に合致
      case transform x of
        -- 変換失敗したら 後続を処理 戻り値に自身のerrorを追加
        Left err ->
          case findFirstTransformableDetailed predicate transform xs of
            -- 後続もずっと成功していない
            NoTransform errors ->
              NoTransform (err : errors)
            Transformed original index transformedXs errors ->
              Transformed original (index + 1) (x : transformedXs) (err : errors)
        Right transformed ->
          -- 変換成功なら再帰終了
          Transformed x 0 (transformed : xs) []
  | otherwise =
      -- 条件に合致しない
      case findFirstTransformableDetailed predicate transform xs of
        -- 後続も処理成功していない
        NoTransform errors ->
          NoTransform errors
        -- 後続は処理成功している
        Transformed original index transformedXs errors ->
          Transformed original (index + 1) (x : transformedXs) errors
