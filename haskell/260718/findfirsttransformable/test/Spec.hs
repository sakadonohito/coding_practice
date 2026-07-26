{-- There is no module named ‘Main’.
module LibSpec (spec) where

import Lib ( findFirstTransformable )
import Test.Hspec

safeDivide100 :: Int -> Either String Int
safeDivide100 0 = Left "division by zero"
safeDivide100 x
  | 100 `mod` x == 0 = Right (100 `div` x)
  | otherwise = Left "not divisible"

spec :: Spec
spec = do
  describe "findFirstTransformable" $ do
    it "条件に一致し、最初に変換成功した要素を置き換える" $ do
      findFirstTransformable even safeDivide100 [3, 0, 4, 8]
        `shouldBe` Just ((4, 2), [3, 0, 25, 8])

    it "変換に失敗した要素を飛ばして次を調べる" $ do
      findFirstTransformable even safeDivide100 [3, 6, 7, 8]
        `shouldBe` Just ((8, 3), [3, 6, 7, 12])

    it "条件に一致する要素が存在しない場合はNothingを返す" $ do
      findFirstTransformable even safeDivide100 [1, 3, 5]
        `shouldBe` Nothing

    it "条件に一致しても全て変換失敗ならNothingを返す" $ do
      findFirstTransformable even safeDivide100 [3, 6, 7]
        `shouldBe` Nothing

    it "空リストならNothingを返す" $ do
      findFirstTransformable even safeDivide100 []
        `shouldBe` Nothing

    it "先頭で変換に成功した場合はインデックス0を返す" $ do
      findFirstTransformable even safeDivide100 [4, 8, 10]
        `shouldBe` Just ((4, 0), [25, 8, 10])
--}

module Main (main) where

import Lib ( findFirstTransformable )
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
  describe "findFirstTransformable" $ do
    it "条件に一致し、最初に変換成功した要素を置き換える" $ do
      findFirstTransformable even safeDivide100 [3, 0, 4, 8]
        `shouldBe` Just ((4, 2), [3, 0, 25, 8])

    it "変換に失敗した要素を飛ばして次を調べる" $ do
      findFirstTransformable even safeDivide100 [3, 6, 7, 20]
        `shouldBe` Just ((20, 3), [3, 6, 7, 5])

    it "条件に一致する要素が存在しない場合はNothingを返す" $ do
      findFirstTransformable even safeDivide100 [1, 3, 5]
        `shouldBe` Nothing

    it "条件に一致しても全て変換失敗ならNothingを返す" $ do
      findFirstTransformable even safeDivide100 [3, 6, 7]
        `shouldBe` Nothing

    it "空リストならNothingを返す" $ do
      findFirstTransformable even safeDivide100 []
        `shouldBe` Nothing

    it "先頭で変換に成功した場合はインデックス0を返す" $ do
      findFirstTransformable even safeDivide100 [4, 8, 10]
        `shouldBe` Just ((4, 0), [25, 8, 10])
