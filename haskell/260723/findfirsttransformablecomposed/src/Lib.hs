module Lib
  ( TransformSuccess (..),
    TransformResult (..),
    mapTransformSuccess,
    advanceSuccess,
    recordTransformError,
    findFirstTransformableComposed,
  )
where

data TransformSuccess = TransformSuccess
  { originalValue :: Int,
    transformedIndex :: Int,
    transformedList :: [Int],
    errorsBeforeSuccess :: [String]
  }
  deriving (Eq, Show)

data TransformResult
  = NoTransform [String]
  | Transformed TransformSuccess
  deriving (Eq, Show)

advanceSuccess ::
  Int ->
  TransformSuccess ->
  TransformSuccess
advanceSuccess x success =
  success
    { transformedIndex = transformedIndex success + 1,
      transformedList = x : transformedList success
    }

recordTransformError ::
  String ->
  TransformSuccess ->
  TransformSuccess
recordTransformError str success =
  success
    { errorsBeforeSuccess = str : errorsBeforeSuccess success
    }

mapTransformSuccess ::
  (TransformSuccess -> TransformSuccess) ->
  TransformResult ->
  TransformResult
mapTransformSuccess _ (NoTransform errors) = NoTransform errors
mapTransformSuccess update (Transformed success) =
  Transformed (update success)

findFirstTransformableComposed ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  TransformResult
findFirstTransformableComposed _ _ [] = NoTransform []
findFirstTransformableComposed predicate transform (x : xs)
  | predicate x =
      -- 条件に合致した場合
      case transform x of
        -- 変換失敗
        Left err ->
          case findFirstTransformableComposed predicate transform xs of
            -- 後続も失敗
            NoTransform errors ->
              NoTransform (err : errors)
            -- 後続で成功
            -- recordTransformError err (advanceSuccess x success)
            result ->
              mapTransformSuccess
                ( -- err を追加する
                  recordTransformError err
                    .
                    -- 後続が成功した場合の処理
                    advanceSuccess x
                )
                result
        -- 変換成功
        Right transformed ->
          -- 再帰終了
          Transformed
            TransformSuccess
              { originalValue = x,
                transformedIndex = 0,
                transformedList = transformed : xs,
                errorsBeforeSuccess = []
              }
  | otherwise =
      mapTransformSuccess
        -- 後続が成功した場合の処理
        (advanceSuccess x)
        -- NoTransformが戻ってきた場合はそのまま返す
        (findFirstTransformableComposed predicate transform xs)
