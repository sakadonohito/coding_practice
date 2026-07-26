module Main (main) where

import Lib ( firstPositive )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "firstPositive" $ do
    it "returns Nothing for an empty list" $
      firstPositive [] `shouldBe` Nothing

    it "returns Nothing when no positive value exists" $
      firstPositive [-3, 0, -1] `shouldBe` Nothing

    it "returns the first value when it is positive" $
      firstPositive [4, 2, 8] `shouldBe` Just 4

    it "returns the first positive value found later" $
      firstPositive [-3, 0, 5, 2] `shouldBe` Just 5

    it "does not treat zero as positive" $
      firstPositive [0, -1, 7] `shouldBe` Just 7
