module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "evaluateRule" $ do
    it "登録済みの事実を評価する" $ do
      evaluateRule factValue (Fact "isMember")
        `shouldBe` Right True

      evaluateRule factValue (Fact "isSuspended")
        `shouldBe` Right False

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

    it "Notは内側の正常な結果を反転する" $ do
      evaluateRule factValue (Not (Fact "isMember"))
        `shouldBe` Right False

    it "空のAllをTrueとして扱う" $ do
      evaluateRule factValue (All [])
        `shouldBe` Right True

    it "空のAnyをFalseとして扱う" $ do
      evaluateRule factValue (Any [])
        `shouldBe` Right False

    it "必要な事実が未登録なら名前付きのエラーを返す" $ do
      evaluateRule factValue (Fact "hasPaidPlan")
        `shouldBe` Left (UnknownFact "hasPaidPlan")

    it "AllはFalseが見つかる前の未登録事実をエラーにする" $ do
      let rule =
            All
              [ Fact "hasPaidPlan",
                Fact "isSuspended"
              ]

      evaluateRule factValue rule
        `shouldBe` Left (UnknownFact "hasPaidPlan")

    it "AllはFalseが見つかった後のルールを評価しない" $ do
      let rule =
            All
              [ Fact "isSuspended",
                Fact "hasPaidPlan"
              ]

      evaluateRule factValue rule
        `shouldBe` Right False

    it "AnyはTrueが見つかった後のルールを評価しない" $ do
      let rule =
            Any
              [ Fact "isMember",
                Fact "hasPaidPlan"
              ]

      evaluateRule factValue rule
        `shouldBe` Right True

    it "Notの内側のエラーをそのまま返す" $ do
      evaluateRule factValue (Not (Fact "hasPaidPlan"))
        `shouldBe` Left (UnknownFact "hasPaidPlan")

factValue :: String -> Maybe Bool
factValue "isMember" = Just True
factValue "isAdmin" = Just False
factValue "isSuspended" = Just False
factValue _ = Nothing
