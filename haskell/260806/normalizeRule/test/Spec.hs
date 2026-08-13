module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "normalizeRule" $ do
    it "否定されていないFactをPositiveFactにする" $ do
      normalizeRule (Fact "isMember")
        `shouldBe` Right (PositiveFact "isMember")

    it "Factに付いた否定をNegativeFactにする" $ do
      normalizeRule (Not (Fact "isSuspended"))
        `shouldBe` Right (NegativeFact "isSuspended")

    it "AllとAnyの構造および子の順序を保つ" $ do
      let rule =
            All
              [ Fact "isMember",
                Any [Fact "isAdmin", Fact "hasPaidPlan"]
              ]

      normalizeRule rule
        `shouldBe` Right
          ( AllOf
              [ PositiveFact "isMember",
                AnyOf
                  [ PositiveFact "isAdmin",
                    PositiveFact "hasPaidPlan"
                  ]
              ]
          )

    it "Allの否定を各子の否定を持つAnyOfへ変換する" $ do
      normalizeRule
        (Not (All [Fact "isMember", Fact "hasPaidPlan"]))
        `shouldBe` Right
          ( AnyOf
              [ NegativeFact "isMember",
                NegativeFact "hasPaidPlan"
              ]
          )

    it "Anyの否定を各子の否定を持つAllOfへ変換する" $ do
      normalizeRule
        (Not (Any [Fact "isAdmin", Fact "isOwner"]))
        `shouldBe` Right
          ( AllOf
              [ NegativeFact "isAdmin",
                NegativeFact "isOwner"
              ]
          )

    it "二重否定を打ち消す" $ do
      normalizeRule (Not (Not (Fact "isMember")))
        `shouldBe` Right (PositiveFact "isMember")

    it "異常に深い否定でも奇数回ならNegativeFactにする" $ do
      normalizeRule
        (Not (Not (Not (Not (Not (Fact "isMember"))))))
        `shouldBe` Right (NegativeFact "isMember")

    it "否定が入れ子になったAllとAnyを内側まで変換する" $ do
      let rule =
            Not
              ( All
                  [ Fact "isMember",
                    Any
                      [ Fact "isAdmin",
                        Not (Fact "isSuspended")
                      ]
                  ]
              )

      normalizeRule rule
        `shouldBe` Right
          ( AnyOf
              [ NegativeFact "isMember",
                AllOf
                  [ NegativeFact "isAdmin",
                    PositiveFact "isSuspended"
                  ]
              ]
          )

    it "空のAllとAnyをそのままの種類で変換する" $ do
      normalizeRule (All []) `shouldBe` Right (AllOf [])
      normalizeRule (Any []) `shouldBe` Right (AnyOf [])

    it "空のAllとAnyを否定すると種類を入れ替える" $ do
      normalizeRule (Not (All [])) `shouldBe` Right (AnyOf [])
      normalizeRule (Not (Any [])) `shouldBe` Right (AllOf [])

    it "空の事実名をエラーにする" $ do
      normalizeRule (Fact "")
        `shouldBe` Left FactNameMustNotBeEmpty

    it "入れ子の途中に空の事実名があってもエラーにする" $ do
      normalizeRule
        (All [Fact "isMember", Not (Any [Fact ""])])
        `shouldBe` Left FactNameMustNotBeEmpty

    it "空白だけの事実名は今回の仕様では有効とする" $ do
      normalizeRule (Not (Fact " "))
        `shouldBe` Right (NegativeFact " ")
