module Main (main) where

import Lib ( findAndTransformWithIndex )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "findAndTransformWithIndex" $ do
    it "returns the matched value and its index" $
      findAndTransformWithIndex even (* 10) [1, 3, 4, 6]
        `shouldBe` (Just (4, 2), [1, 3, 40, 6])

    it "returns index zero when the first element matches" $
      findAndTransformWithIndex (> 5) (+ 100) [8, 2, 9]
        `shouldBe` (Just (8, 0), [108, 2, 9])

    it "transforms only the first matching element" $
      findAndTransformWithIndex odd (+ 1) [2, 4, 5, 7]
        `shouldBe` (Just (5, 2), [2, 4, 6, 7])

    it "returns Nothing and the original list when nothing matches" $
      findAndTransformWithIndex odd (+ 1) [2, 4, 6]
        `shouldBe` (Nothing, [2, 4, 6])

    it "works for an empty list" $
      findAndTransformWithIndex (> 0) (* 2) []
        `shouldBe` (Nothing, [])
