module Lib
  ( TransformSuccess (..),
    TransformResult (..),
    mapTransformSuccess,
    findFirstTransformableMapped,
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

mapTransformSuccess ::
  (TransformSuccess -> TransformSuccess) ->
  TransformResult ->
  TransformResult
mapTransformSuccess _ (NoTransform errors) = NoTransform errors
mapTransformSuccess update (Transformed success) =
  Transformed (update success)

findFirstTransformableMapped ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  TransformResult
findFirstTransformableMapped _ _ [] = NoTransform []
findFirstTransformableMapped predicate transform (x : xs)
  | predicate x =
      -- 条件に合致した場合
      case transform x of
        -- 変換失敗
        Left err ->
          case findFirstTransformableMapped predicate transform xs of
            -- 後続も失敗
            NoTransform errors ->
              NoTransform (err : errors)
            -- 後続で成功
            result ->
              mapTransformSuccess
                -- 第1引数:処理
                ( \success ->
                    success
                      { transformedIndex = transformedIndex success + 1,
                        transformedList = x : transformedList success,
                        errorsBeforeSuccess = err : errorsBeforeSuccess success
                      }
                )
                -- 第2引数:データ(TransformResult(TransformSuccess))
                result
        -- 変換成功
        Right transformed ->
          -- 再帰終了
          Transformed
            ( TransformSuccess
                { originalValue = x,
                  transformedIndex = 0,
                  transformedList = transformed : xs,
                  errorsBeforeSuccess = []
                }
            )
  | otherwise =
      mapTransformSuccess
        -- 第1引数:処理
        ( \success ->
            success
              { transformedIndex = transformedIndex success + 1,
                transformedList = x : transformedList success
              }
        )
        -- 第2引数:データ(TransformResult(TransformSuccess) or TransformResult(NoTransform))
        -- NoTransformが戻ってきた場合はそのまま返す
        (findFirstTransformableMapped predicate transform xs)
