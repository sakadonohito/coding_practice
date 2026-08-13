module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "numberSections" $ do
    it "空の目次を空の結果にする" $ do
      numberSections [] `shouldBe` Right []

    it "子を持たない1つの節へ番号1を付ける" $ do
      numberSections [Section "はじめに" []]
        `shouldBe` Right
          [NumberedSection 1 "はじめに" []]

    it "親を先に番号付けしてから子を左から処理する" $ do
      let sections =
            [ Section
                "はじめに"
                [ Section "目的" [],
                  Section "用語" []
                ],
              Section "付録" []
            ]

      numberSections sections
        `shouldBe` Right
          [ NumberedSection
              1
              "はじめに"
              [ NumberedSection 2 "目的" [],
                NumberedSection 3 "用語" []
              ],
            NumberedSection 4 "付録" []
          ]

    it "深い子孫で使った番号の続きから次の兄弟を番号付けする" $ do
      let sections =
            [ Section
                "第1部"
                [ Section
                    "第1章"
                    [Section "第1節" []],
                  Section "第2章" []
                ],
              Section "第2部" []
            ]

      numberSections sections
        `shouldBe` Right
          [ NumberedSection
              1
              "第1部"
              [ NumberedSection
                  2
                  "第1章"
                  [NumberedSection 3 "第1節" []],
                NumberedSection 4 "第2章" []
              ],
            NumberedSection 5 "第2部" []
          ]

    it "同じタイトルでも別の通し番号を付ける" $ do
      numberSections
        [Section "概要" [], Section "概要" []]
        `shouldBe` Right
          [ NumberedSection 1 "概要" [],
            NumberedSection 2 "概要" []
          ]

    it "空白だけのタイトルは有効とする" $ do
      numberSections [Section " " []]
        `shouldBe` Right
          [NumberedSection 1 " " []]

    it "先頭の節の空タイトルを番号1のエラーにする" $ do
      numberSections [Section "" []]
        `shouldBe` Left (EmptySectionTitle 1)

    it "有効な節の後にある空タイトルへ予定番号を付ける" $ do
      numberSections
        [ Section
            "親"
            [ Section "子1" [],
              Section "" []
            ]
        ]
        `shouldBe` Left (EmptySectionTitle 3)

    it "深い子孫を数えた後の空タイトルへ正しい予定番号を付ける" $ do
      numberSections
        [ Section
            "第1部"
            [Section "第1章" [Section "第1節" []]],
          Section "" []
        ]
        `shouldBe` Left (EmptySectionTitle 4)

    it "複数の空タイトルがあっても先行順で最初のエラーを返す" $ do
      numberSections
        [ Section
            "親"
            [ Section "" [],
              Section "" []
            ],
          Section "" []
        ]
        `shouldBe` Left (EmptySectionTitle 2)
