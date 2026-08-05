module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "countFacts" $ do
    it "入れ子になったすべてのFactを数える" $ do
      let rule =
            All
              [ Fact "isMember",
                Any
                  [ Fact "isAdmin",
                    Not (Fact "isSuspended")
                  ]
              ]

      countFacts rule `shouldBe` 3

    it "同じ名前のFactも出現回数だけ数える" $ do
      countFacts
        (All [Fact "isMember", Fact "isMember"])
        `shouldBe` 2

    it "空のAllとAnyにはFactがない" $ do
      countFacts (All []) `shouldBe` 0
      countFacts (Any []) `shouldBe` 0

    it "Notが何重でも内側のFactだけを数える" $ do
      countFacts (Not (Not (Fact "isMember")))
        `shouldBe` 1

  describe "evaluateRule" $ do
    it "All・Any・Notを入れ子にしたルールを評価する" $ do
      let rule =
            All
              [ Fact "isMember",
                Any
                  [ Fact "isAdmin",
                    Not (Fact "isSuspended")
                  ]
              ]

      evaluateRule factValue rule
        `shouldBe` Right True

    it "空のAllとAnyの意味を呼び出し側の関数が決める" $ do
      evaluateRule factValue (All [])
        `shouldBe` Right True
      evaluateRule factValue (Any [])
        `shouldBe` Right False

    it "未登録のFactを名前付きのエラーにする" $ do
      evaluateRule factValue (Fact "hasPaidPlan")
        `shouldBe` Left (UnknownFact "hasPaidPlan")

    it "Allでは左側の未登録Factを後続のFalseより先に返す" $ do
      evaluateRule
        factValue
        (All [Fact "hasPaidPlan", Fact "isSuspended"])
        `shouldBe` Left (UnknownFact "hasPaidPlan")

    it "AllはFalseの後にある未登録Factを評価しない" $ do
      evaluateRule
        factValue
        (All [Fact "isSuspended", Fact "hasPaidPlan"])
        `shouldBe` Right False

    it "AnyはTrueの後にある未登録Factを評価しない" $ do
      evaluateRule
        factValue
        (Any [Fact "isMember", Fact "hasPaidPlan"])
        `shouldBe` Right True

    it "Notは内側のエラーをそのまま返す" $ do
      evaluateRule factValue (Not (Fact "hasPaidPlan"))
        `shouldBe` Left (UnknownFact "hasPaidPlan")

factValue :: String -> Maybe Bool
factValue "isMember" = Just True
factValue "isAdmin" = Just False
factValue "isSuspended" = Just False
factValue _ = Nothing
