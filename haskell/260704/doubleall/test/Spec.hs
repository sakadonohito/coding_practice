module Main (main) where

import Lib (doubleAll, doubleMap)
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "doubleAll" $ do
    it "doubleAll [] == []" $
      doubleAll [] `shouldBe` []

    it "doubleAll [1] == [2]" $
      doubleAll [1] `shouldBe` [2]

    it "doubleAll [1, 2, 3] == [2, 4, 6]" $
      doubleAll [1, 2, 3] `shouldBe` [2, 4, 6]

    it "doubleAll [-1, 0, 5] == [-2, 0, 10]" $
      doubleAll [-1, 0, 5] `shouldBe` [-2, 0, 10]

  describe "doubleMap" $ do
    it "doubleMap [] == []" $
      doubleMap [] `shouldBe` []

    it "doubleMap [1] == [2]" $
      doubleMap [1] `shouldBe` [2]

    it "doubleMap [1, 2, 3] == [2, 4, 6]" $
      doubleMap [1, 2, 3] `shouldBe` [2, 4, 6]

    it "doubleMap [-1, 0, 5] == [-2, 0, 10]" $
      doubleMap [-1, 0, 5] `shouldBe` [-2, 0, 10]
