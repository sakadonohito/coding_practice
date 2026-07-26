module Main (main) where

import Lib (sumList)
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "sumList" $ do
    it "sumList [] == 0" $
      sumList [] `shouldBe` 0

    it "sumList [5] == 5" $
      sumList [5] `shouldBe` 5

    it "sumList [1, 2, 3] == 6" $
      sumList [1, 2, 3] `shouldBe` 6

    it "sumList [-1, 0, 5] == 4" $
      sumList [-1, 0, 5] `shouldBe` 4

    it "sumList [10, -3, -7] == 0" $
      sumList [10, -3, -7] `shouldBe` 0
