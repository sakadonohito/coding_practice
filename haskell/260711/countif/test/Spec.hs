module Main (main) where

import Lib ( countIf )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "countIf" $ do
    it "counts positive numbers" $
      countIf (> 0) [1, -2, 3, 0] `shouldBe` 2

    it "counts even numbers" $
      countIf even [1, 2, 3, 4, 5, 6] `shouldBe` 3

    it "counts odd numbers" $
      countIf odd [2, 4, 6] `shouldBe` 0

    it "counts numbers less than 10" $
      countIf (< 10) [8, 12, 3, 15] `shouldBe` 2

    it "returns 0 for an empty list" $
      countIf (> 0) [] `shouldBe` 0
