module Main (main) where

import Lib
  ( TransformResult (..),
    TransformSuccess (..),
    findFirstTransformableRecord,
  )
import Test.Hspec
  ( describe,
    hspec,
    it,
    shouldBe,
  )

safeDivide100 :: Int -> Either String Int
safeDivide100 0 = Left "division by zero"
safeDivide100 x
  | 100 `mod` x == 0 = Right (100 `div` x)
  | otherwise = Left "not divisible"

main :: IO ()
main = hspec $ do
  describe "findFirstTransformableRecord" $ do
    it "失敗内容を保存しながら最初の変換成功を返す" $ do
      findFirstTransformableRecord
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
      findFirstTransformableRecord
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

    it "全て変換失敗ならエラー一覧を返す" $ do
      findFirstTransformableRecord
        even
        safeDivide100
        [6, 14, 7]
        `shouldBe` NoTransform
          ["not divisible", "not divisible"]

    it "条件に一致する要素がなければ空のエラー一覧を返す" $ do
      findFirstTransformableRecord
        even
        safeDivide100
        [1, 3, 5]
        `shouldBe` NoTransform []

    it "先頭で成功した場合は位置0と空のエラー一覧を返す" $ do
      findFirstTransformableRecord
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
      findFirstTransformableRecord
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
      findFirstTransformableRecord
        even
        safeDivide100
        []
        `shouldBe` NoTransform []
