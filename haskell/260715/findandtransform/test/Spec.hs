module Main (main) where

import Lib ( findAndTransform )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "findAndTransform" $ do
    it "returns the first matching value and updates it" $
      findAndTransform even (* 10) [1, 2, 4, 6]
        `shouldBe` (Just 2, [1, 20, 4, 6])

    it "works with another predicate" $
      findAndTransform (> 5) (+ 100) [2, 8, 9]
        `shouldBe` (Just 8, [2, 108, 9])

    it "returns Nothing when nothing matches" $
      findAndTransform odd (+ 1) [2, 4, 6]
        `shouldBe` (Nothing, [2, 4, 6])

    it "works with an empty list" $
      findAndTransform (> 0) (* 2) []
        `shouldBe` (Nothing, [])
