module Main (main) where

import Lib ( partitionFirst )
import Test.Hspec ( hspec, describe, it, shouldBe )

main :: IO ()
main = hspec $ do
  describe "partitionFirst" $ do
    it "splits before the first matching element" $
      partitionFirst even [1, 3, 4, 6]
        `shouldBe` ([1, 3], [4, 6])

    it "returns everything on the left when nothing matches" $
      partitionFirst odd [2, 4, 6]
        `shouldBe` ([2, 4, 6], [])

    it "returns everything on the right when the first element matches" $
      partitionFirst odd [1, 2, 3]
        `shouldBe` ([], [1, 2, 3])

    it "works for an empty list" $
      partitionFirst (> 0) []
        `shouldBe` ([], [])

    it "works with another predicate" $
      partitionFirst (> 5) [2, 8, 9]
        `shouldBe` ([2], [8, 9])
