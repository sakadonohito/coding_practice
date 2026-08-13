module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "mapAccumForestEither" $ do
    it "空のリストでは初期状態をそのまま返す" $ do
      mapAccumForestEither numberLabel 10 []
        `shouldBe` Right (10, [])

    it "最終状態も呼び出し側へ返す" $ do
      mapAccumForestEither
        numberLabel
        4
        [Node "A" [], Node "B" []]
        `shouldBe` Right
          ( 6,
            [ Node (4, "A") [],
              Node (5, "B") []
            ]
          )

    it "stepが決めた幅で状態を更新する" $ do
      let advanceByLength ::
            Int ->
            String ->
            Either NumberingError (Int, Int)
          advanceByLength total label =
            Right (total + length label, total)

      mapAccumForestEither
        advanceByLength
        0
        [ Node "ab" [Node "cde" []],
          Node "f" []
        ]
        `shouldBe` Right
          ( 6,
            [ Node 0 [Node 2 []],
              Node 5 []
            ]
          )

    it "深さ優先・先行順で最初のエラーを返す" $ do
      mapAccumForestEither
        numberLabel
        1
        [ Node "親"
            [ Node "" [],
              Node "" []
            ],
          Node "" []
        ]
        `shouldBe` Left (EmptyLabel 2)

  describe "numberForest" $ do
    it "空の木のリストを空の結果にする" $ do
      numberForest [] `shouldBe` Right []

    it "子を持たない1つのノードへ番号1を付ける" $ do
      numberForest [Node "開始" []]
        `shouldBe` Right [Node (1, "開始") []]

    it "親・子・次の兄弟の順で通し番号を付ける" $ do
      numberForest
        [ Node
            "親"
            [ Node "子1" [],
              Node "子2" []
            ],
          Node "兄弟" []
        ]
        `shouldBe` Right
          [ Node
              (1, "親")
              [ Node (2, "子1") [],
                Node (3, "子2") []
              ],
            Node (4, "兄弟") []
          ]

    it "深い子孫で更新した状態を後続の兄弟へ渡す" $ do
      numberForest
        [ Node "第1部"
            [Node "第1章" [Node "第1節" []]],
          Node "第2部" []
        ]
        `shouldBe` Right
          [ Node
              (1, "第1部")
              [Node (2, "第1章") [Node (3, "第1節") []]],
            Node (4, "第2部") []
          ]

    it "同じラベルでも別々に変換する" $ do
      numberForest [Node "概要" [], Node "概要" []]
        `shouldBe` Right
          [Node (1, "概要") [], Node (2, "概要") []]

    it "空白だけのラベルは有効とする" $ do
      numberForest [Node " " []]
        `shouldBe` Right [Node (1, " ") []]

    it "深い子孫の後にある空ラベルへ予定番号を付ける" $ do
      numberForest
        [ Node "第1部"
            [Node "第1章" [Node "第1節" []]],
          Node "" []
        ]
        `shouldBe` Left (EmptyLabel 4)

numberLabel ::
  Int ->
  String ->
  Either NumberingError (Int, (Int, String))
numberLabel nextNumber label
  | null label = Left (EmptyLabel nextNumber)
  | otherwise =
      Right
        ( nextNumber + 1,
          (nextNumber, label)
        )
