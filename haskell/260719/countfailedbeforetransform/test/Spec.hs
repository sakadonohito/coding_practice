module Main (main) where

import Lib (countFailedBeforeTransform)
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
  describe "countFailedBeforeTransform" $ do

    it "変換失敗を数えながら最初の成功を返す" $ do
      countFailedBeforeTransform even safeDivide100 [3, 6, 7, 20]
        `shouldBe` (1, Just ((20, 3), [3, 6, 7, 5]))

    it "すべて変換失敗なら失敗回数とNothingを返す" $ do
      countFailedBeforeTransform even safeDivide100 [6, 8, 14]
        `shouldBe` (3, Nothing)

    it "条件に一致する要素がなければ失敗回数0でNothing" $ do
      countFailedBeforeTransform even safeDivide100 [1, 3, 5]
        `shouldBe` (0, Nothing)

    it "先頭で成功したら失敗回数0" $ do
      countFailedBeforeTransform even safeDivide100 [4, 6, 8]
        `shouldBe` (0, Just ((4, 0), [25, 6, 8]))

    it "空リストなら失敗回数0でNothing" $ do
      countFailedBeforeTransform even safeDivide100 []
        `shouldBe` (0, Nothing)

    it "途中で複数回失敗してから成功する" $ do
      countFailedBeforeTransform even safeDivide100 [6, 14, 7, 20]
        `shouldBe` (2, Just ((20, 3), [6, 14, 7, 5]))

    it "0で失敗したあと成功する" $ do
      countFailedBeforeTransform even safeDivide100 [0, 20]
        `shouldBe` (1, Just ((20, 1), [0, 5]))
