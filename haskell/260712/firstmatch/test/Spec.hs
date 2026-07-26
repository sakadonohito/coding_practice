module Main (main) where

import Lib ( firstMatch )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "firstMatch" $ do
    it "returns Nothing for an empty list" $
      firstMatch (> 0) [] `shouldBe` Nothing

    it "returns the first positive number" $
      firstMatch (> 0) [-3, 0, 5, 2] `shouldBe` Just 5

    it "returns the first even number" $
      firstMatch even [1, 3, 4, 6] `shouldBe` Just 4

    it "returns Nothing when no element matches" $
      firstMatch odd [2, 4, 6] `shouldBe` Nothing

    it "returns the first number below ten" $
      firstMatch (< 10) [12, 8, 3, 15] `shouldBe` Just 8
