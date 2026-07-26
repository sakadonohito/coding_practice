module Main (main) where

import Lib ( anyPositive )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "anyPositive" $ do
    it "anyPositive [] == False" $
      anyPositive [] `shouldBe` False

    it "anyPositive [1,2,3] == True" $
      anyPositive [1,2,3] `shouldBe` True

    it "anyPositive [-1,0,5] == True" $
      anyPositive [-1,0,5] `shouldBe` True

    it "anyPositive [3,-2,8,0,1] == True" $
      anyPositive [3,-2,8,0,1] `shouldBe` True

    it "anyPositive [-5,-2,0] == False" $
      anyPositive [-5,-2,0] `shouldBe` False

    it "anyPositive [0] == False" $
      anyPositive [0] `shouldBe` False

