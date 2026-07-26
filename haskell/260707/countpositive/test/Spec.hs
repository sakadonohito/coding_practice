module Main (main) where

import Lib ( countPositive )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "countPositive" $ do
    it "countPositive [] == 0" $
      countPositive [] `shouldBe` 0

    it "countPositive [1, 2, 3] == 3" $
      countPositive [1, 2, 3] `shouldBe` 3

    it "countPositive [-1, 0, 5] == 1" $
      countPositive [-1, 0, 5] `shouldBe` 1

    it "countPositive [3, -2, 8, 0, 1] == 3" $
      countPositive [3, -2, 8, 0, 1] `shouldBe` 3

    it "countPositive [-5, -2, 0] == 0" $
      countPositive [-5, -2, 0] `shouldBe` 0
