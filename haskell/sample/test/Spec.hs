module Main where

import Test.Hspec
import Lib

main :: IO ()
main = hspec $ do
  describe "double" $ do
    it "double 3 == 6" $ do
      double 3 `shouldBe` 6
