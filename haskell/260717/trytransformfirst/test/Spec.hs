module Main (main) where

import Lib (tryTransformFirst)
import Test.Hspec
  ( describe,
    hspec,
    it,
    shouldBe,
  )

safeDivide100 :: Int -> Either String Int
safeDivide100 0 = Left "division by zero"
safeDivide100 n = Right (100 `div` n)

main :: IO ()
main = hspec $ do
  describe "tryTransformFirst" $ do
    it "transforms the first matching value" $
      tryTransformFirst even safeDivide100 [1, 4, 6]
        `shouldBe` Right (Just (4, 1), [1, 25, 6])

    it "returns an error when transformation fails" $
      tryTransformFirst even safeDivide100 [1, 0, 4]
        `shouldBe` Left "division by zero"

    it "does not examine later matches after a failure" $
      tryTransformFirst even safeDivide100 [0, 4, 6]
        `shouldBe` Left "division by zero"

    it "transforms only the first matching value" $
      tryTransformFirst even safeDivide100 [2, 4, 10]
        `shouldBe` Right (Just (2, 0), [50, 4, 10])

    it "returns the original list when nothing matches" $
      tryTransformFirst odd safeDivide100 [2, 4, 6]
        `shouldBe` Right (Nothing, [2, 4, 6])

    it "works with an empty list" $
      tryTransformFirst (> 0) safeDivide100 []
        `shouldBe` Right (Nothing, [])
