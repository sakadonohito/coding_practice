module Main (main) where

import Lib ( allPositive )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "allPositive" $ do
    it "allPositive [] == True" $
      allPositive [] `shouldBe` True

    it "allPositive [1,2,3] == True" $
      allPositive [1,2,3] `shouldBe` True

    it "allPositive [-1,2,3] == False" $
      allPositive [-1,2,3] `shouldBe` False

    it "allPositive [3,-2,8,1] == False" $
      allPositive [3,-2,8,1] `shouldBe` False

    it "allPositive [5] == True" $
      allPositive [5] `shouldBe` True

    it "allPositive [0] == False" $
      allPositive [0] `shouldBe` False
