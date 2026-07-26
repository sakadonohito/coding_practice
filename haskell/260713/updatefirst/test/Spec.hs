module Main (main) where

import Lib ( updateFirst )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "updateFirst" $ do
    it "updates the first matching element" $
      updateFirst even (* 10) [1, 2, 4, 6]
        `shouldBe` [1, 20, 4, 6]

    it "does not update later matching elements" $
      updateFirst even (* 10) [2, 4, 6]
        `shouldBe` [20, 4, 6]

    it "can receive a different predicate and transformation" $
      updateFirst (> 0) negate [-2, 0, 3, 5]
        `shouldBe` [-2, 0, -3, 5]

    it "returns the original list when nothing matches" $
      updateFirst odd (+ 1) [2, 4, 6]
        `shouldBe` [2, 4, 6]

    it "returns an empty list for an empty list" $
      updateFirst (> 0) (* 2) []
        `shouldBe` []
