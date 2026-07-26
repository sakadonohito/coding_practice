module Main (main) where

import Lib
  ( TransformResult (..),
    TransformSuccess (..),
    advanceSuccess,
    findFirstTransformableComposed,
    mapTransformSuccess,
    recordTransformError,
  )
import Test.Hspec
  ( describe,
    hspec,
    it,
    shouldBe,
  )

safeDivide100 :: Int -> Either String Int
safeDivide100 0 =
  Left "division by zero"
safeDivide100 x
  | 100 `mod` x == 0 =
      Right (100 `div` x)
  | otherwise =
      Left "not divisible"

sampleSuccess :: TransformSuccess
sampleSuccess =
  TransformSuccess
    { originalValue = 20,
      transformedIndex = 2,
      transformedList = [1, 3, 5],
      errorsBeforeSuccess = []
    }

main :: IO ()
main = hspec $ do
  describe "advanceSuccess" $ do
    it "位置を1増やして現在の要素をリストの先頭へ戻す" $ do
      advanceSuccess 7 sampleSuccess
        `shouldBe` TransformSuccess
          { originalValue = 20,
            transformedIndex = 3,
            transformedList = [7, 1, 3, 5],
            errorsBeforeSuccess = []
          }

  describe "recordTransformError" $ do
    it "成功情報のエラー一覧へ新しいエラーを追加する" $ do
      recordTransformError
        "not divisible"
        sampleSuccess
        `shouldBe` TransformSuccess
          { originalValue = 20,
            transformedIndex = 2,
            transformedList = [1, 3, 5],
            errorsBeforeSuccess = ["not divisible"]
          }

  describe "関数合成" $ do
    it "要素の復元とエラー追加を順番に適用する" $ do
      (recordTransformError "not divisible" . advanceSuccess 6)
        sampleSuccess
        `shouldBe` TransformSuccess
          { originalValue = 20,
            transformedIndex = 3,
            transformedList = [6, 1, 3, 5],
            errorsBeforeSuccess = ["not divisible"]
          }

    it "合成した更新関数をTransformResultへ適用できる" $ do
      mapTransformSuccess
        (recordTransformError "not divisible" . advanceSuccess 6)
        (Transformed sampleSuccess)
        `shouldBe` Transformed
          TransformSuccess
            { originalValue = 20,
              transformedIndex = 3,
              transformedList = [6, 1, 3, 5],
              errorsBeforeSuccess = ["not divisible"]
            }

  describe "findFirstTransformableComposed" $ do
    it "失敗内容を保存しながら最初の変換成功を返す" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        [3, 6, 7, 20]
        `shouldBe` Transformed
          TransformSuccess
            { originalValue = 20,
              transformedIndex = 3,
              transformedList = [3, 6, 7, 5],
              errorsBeforeSuccess = ["not divisible"]
            }

    it "異なる種類のエラーを発生順に保存する" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        [0, 6, 20]
        `shouldBe` Transformed
          TransformSuccess
            { originalValue = 20,
              transformedIndex = 2,
              transformedList = [0, 6, 5],
              errorsBeforeSuccess =
                ["division by zero", "not divisible"]
            }

    it "全ての変換が失敗した場合はエラー一覧を返す" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        [6, 14, 7]
        `shouldBe` NoTransform
          ["not divisible", "not divisible"]

    it "条件に一致する要素がなければ空のエラー一覧を返す" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        [1, 3, 5]
        `shouldBe` NoTransform []

    it "先頭の要素で成功した場合は位置0を返す" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        [4, 6, 8]
        `shouldBe` Transformed
          TransformSuccess
            { originalValue = 4,
              transformedIndex = 0,
              transformedList = [25, 6, 8],
              errorsBeforeSuccess = []
            }

    it "条件不一致の要素も変換後リストへ戻す" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        [1, 3, 20]
        `shouldBe` Transformed
          TransformSuccess
            { originalValue = 20,
              transformedIndex = 2,
              transformedList = [1, 3, 5],
              errorsBeforeSuccess = []
            }

    it "空リストなら変換なしを返す" $ do
      findFirstTransformableComposed
        even
        safeDivide100
        []
        `shouldBe` NoTransform []
