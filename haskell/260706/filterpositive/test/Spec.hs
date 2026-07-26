module Main (main) where

import Lib ( filterPositive, filterPositiveGuard )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "filterPositive" $ do
    it "filterPositive [] == []" $
      filterPositive [] `shouldBe` []

    it "filterPositive [1, 2, 3] == [1, 2, 3]" $
      filterPositive [1, 2, 3] `shouldBe` [1, 2, 3]

    it "filterPositive [-1, 0, 5] == [5]" $
      filterPositive [-1, 0, 5] `shouldBe` [5]

    it "filterPositive [3, -2, 8, 0, 1] == [3, 8, 1]" $
      filterPositive [3, -2, 8, 0, 1] `shouldBe` [3, 8, 1]

    it "filterPositive [-5, -2, 0] == []" $
      filterPositive [-5, -2, 0] `shouldBe` []

  describe "filterPositiveGuard" $ do
    it "filterPositiveGuard [] == []" $
      filterPositiveGuard [] `shouldBe` []

    it "filterPositiveGuard [1, 2, 3] == [1, 2, 3]" $
      filterPositiveGuard [1, 2, 3] `shouldBe` [1, 2, 3]

    it "filterPositiveGuard [-1, 0, 5] == [5]" $
      filterPositiveGuard [-1, 0, 5] `shouldBe` [5]

    it "filterPositiveGuard [3, -2, 8, 0, 1] == [3, 8, 1]" $
      filterPositiveGuard [3, -2, 8, 0, 1] `shouldBe` [3, 8, 1]

    it "filterPositiveGuard [-5, -2, 0] == []" $
      filterPositiveGuard [-5, -2, 0] `shouldBe` []
