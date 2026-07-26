module Lib
  ( TransformSuccess (..),
    TransformResult (..),
    findFirstTransformableRecord,
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

findFirstTransformableRecord ::
  (Int -> Bool) ->
  (Int -> Either String Int) ->
  [Int] ->
  TransformResult
findFirstTransformableRecord _ _ [] = NoTransform []
findFirstTransformableRecord predicate transform (x : xs)
  | predicate x =
      -- 条件に合致した場合
      case transform x of
        -- 変換失敗
        Left err ->
          case findFirstTransformableRecord predicate transform xs of
            -- 後続も失敗
            NoTransform errors ->
              NoTransform (err : errors)
            -- 後続で成功
            Transformed (TransformSuccess {originalValue = ov, transformedIndex = ti, transformedList = tl, errorsBeforeSuccess = ebs}) ->
              Transformed
                ( TransformSuccess
                    { originalValue = ov,
                      transformedIndex = ti + 1,
                      transformedList = x : tl,
                      errorsBeforeSuccess = err : ebs
                    }
                )
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
      -- 条件に合致しない場合
      case findFirstTransformableRecord predicate transform xs of
        -- 後続も処理失敗
        NoTransform errors ->
          NoTransform errors
        -- 後続は処理成功
        Transformed (TransformSuccess {originalValue = ov, transformedIndex = ti, transformedList = tl, errorsBeforeSuccess = ebs}) ->
          Transformed
            ( TransformSuccess
                { originalValue = ov,
                  transformedIndex = ti + 1,
                  transformedList = x : tl,
                  errorsBeforeSuccess = ebs
                }
            )

{-
条件に一致しない要素
\* transform は実行しない
\* 後続を再帰的に処理する
\* 後続で成功していたら、現在の x を変換後リストの先頭へ戻す
\* 成功位置を1増やす
\* エラー一覧は変更しない

成功
Transformed
  TransformSuccess
    { originalValue = x,
      transformedIndex = 0,
      transformedList = transformed : xs,
      errorsBeforeSuccess = []
    }

-}
