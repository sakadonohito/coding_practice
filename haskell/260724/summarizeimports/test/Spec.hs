module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "addImportResult" $ do
    it "成功した人物を importedPeople に追加する" $ do
      let alice =
            Person
              { personName = "Alice"
              , personAge = 30
              }

          initialSummary =
            ImportSummary
              { importedPeople = []
              , importErrors = []
              }

          expected =
            ImportSummary
              { importedPeople = [alice]
              , importErrors = []
              }

      addImportResult (Right alice) initialSummary
        `shouldBe` expected

    it "失敗理由を importErrors に追加する" $ do
      let initialSummary =
            ImportSummary
              { importedPeople = []
              , importErrors = []
              }

          expected =
            ImportSummary
              { importedPeople = []
              , importErrors = [EmptyName]
              }

      addImportResult (Left EmptyName) initialSummary
        `shouldBe` expected

    it "成功を追加しても既存のエラーを変更しない" $ do
      let alice =
            Person
              { personName = "Alice"
              , personAge = 30
              }

          initialSummary =
            ImportSummary
              { importedPeople = []
              , importErrors = [InvalidAge (-1)]
              }

          expected =
            ImportSummary
              { importedPeople = [alice]
              , importErrors = [InvalidAge (-1)]
              }

      addImportResult (Right alice) initialSummary
        `shouldBe` expected

    it "失敗を追加しても既存の人物を変更しない" $ do
      let alice =
            Person
              { personName = "Alice"
              , personAge = 30
              }

          initialSummary =
            ImportSummary
              { importedPeople = [alice]
              , importErrors = []
              }

          expected =
            ImportSummary
              { importedPeople = [alice]
              , importErrors = [EmptyName]
              }

      addImportResult (Left EmptyName) initialSummary
        `shouldBe` expected

  describe "summarizeImports" $ do
    it "空のリストから空の集計結果を返す" $ do
      let expected =
            ImportSummary
              { importedPeople = []
              , importErrors = []
              }

      summarizeImports []
        `shouldBe` expected

    it "成功だけのリストを集計する" $ do
      let alice =
            Person
              { personName = "Alice"
              , personAge = 30
              }

          bob =
            Person
              { personName = "Bob"
              , personAge = 25
              }

          results =
            [ Right alice
            , Right bob
            ]

          expected =
            ImportSummary
              { importedPeople = [alice, bob]
              , importErrors = []
              }

      summarizeImports results
        `shouldBe` expected

    it "失敗だけのリストを集計する" $ do
      let results =
            [ Left EmptyName
            , Left (InvalidAge (-1))
            ]

          expected =
            ImportSummary
              { importedPeople = []
              , importErrors =
                  [ EmptyName
                  , InvalidAge (-1)
                  ]
              }

      summarizeImports results
        `shouldBe` expected

    it "成功と失敗が混在した結果を別々に集計する" $ do
      let alice =
            Person
              { personName = "Alice"
              , personAge = 30
              }

          bob =
            Person
              { personName = "Bob"
              , personAge = 25
              }

          results =
            [ Right alice
            , Left EmptyName
            , Right bob
            , Left (InvalidAge 150)
            ]

          expected =
            ImportSummary
              { importedPeople = [alice, bob]
              , importErrors =
                  [ EmptyName
                  , InvalidAge 150
                  ]
              }

      summarizeImports results
        `shouldBe` expected

    it "同じ種類のエラーが複数回発生してもすべて保持する" $ do
      let results =
            [ Left EmptyName
            , Left EmptyName
            ]

          expected =
            ImportSummary
              { importedPeople = []
              , importErrors =
                  [ EmptyName
                  , EmptyName
                  ]
              }

      summarizeImports results
        `shouldBe` expected

    it "年齢の境界値を含む人物も成功結果としてそのまま保持する" $ do
      let youngest =
            Person
              { personName = "Youngest"
              , personAge = 0
              }

          oldest =
            Person
              { personName = "Oldest"
              , personAge = 120
              }

          results =
            [ Right youngest
            , Right oldest
            ]

          expected =
            ImportSummary
              { importedPeople = [youngest, oldest]
              , importErrors = []
              }

      summarizeImports results
        `shouldBe` expected
