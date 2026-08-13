module Main (main) where

import Lib
import Test.Hspec

data Recorded = Recorded
  { recordedPath :: [Int],
    recordedValue :: String,
    recordedChildren :: [Recorded]
  }
  deriving (Eq, Show)

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "foldForestBottomUpWithPathEither" $ do
    it "空の木ではcombineを使わず空の結果を返す" $ do
      foldForestBottomUpWithPathEither recordNode ([] :: [Tree String])
        `shouldBe` Right []

    it "葉では変換済みの子として空リストを渡す" $ do
      foldForestBottomUpWithPathEither
        recordNode
        [Node "葉" []]
        `shouldBe` Right
          [Recorded [1] "葉" []]

    it "変換済みの子を入力順のまま親へ渡す" $ do
      foldForestBottomUpWithPathEither
        recordNode
        [ Node
            "親"
            [ Node "子1" [],
              Node "子2" []
            ]
        ]
        `shouldBe` Right
          [ Recorded
              [1]
              "親"
              [ Recorded [1, 1] "子1" [],
                Recorded [1, 2] "子2" []
              ]
          ]

    it "各階層で兄弟番号を1から数え直す" $ do
      foldForestBottomUpWithPathEither
        recordNode
        [ Node "A" [Node "A-1" []],
          Node "B" [Node "B-1" []]
        ]
        `shouldBe` Right
          [ Recorded [1] "A" [Recorded [1, 1] "A-1" []],
            Recorded [2] "B" [Recorded [2, 1] "B-1" []]
          ]

    it "子が失敗したら親の処理へ進まず子のエラーを返す" $ do
      foldForestBottomUpWithPathEither
        rejectEmptyNode
        [Node "" [Node "" []]]
        `shouldBe` Left (EmptyTitle [1, 1])

    it "左の部分木のエラーで後続の兄弟を処理しない" $ do
      foldForestBottomUpWithPathEither
        rejectEmptyNode
        [ Node "A" [Node "" []],
          Node "" []
        ]
        `shouldBe` Left (EmptyTitle [1, 1])

  describe "summarizeOutline" $ do
    it "空の目次を空の結果にする" $ do
      summarizeOutline [] `shouldBe` Right []

    it "葉の部分木の節数を1にする" $ do
      summarizeOutline [Node "概要" []]
        `shouldBe` Right
          [OutlineSummary [1] "概要" 1 []]

    it "子孫を含む部分木の節数を親で集計する" $ do
      summarizeOutline
        [ Node
            "本文"
            [ Node "基本" [Node "型" []],
              Node "応用" []
            ],
          Node "まとめ" []
        ]
        `shouldBe` Right
          [ OutlineSummary
              [1]
              "本文"
              4
              [ OutlineSummary
                  [1, 1]
                  "基本"
                  2
                  [OutlineSummary [1, 1, 1] "型" 1 []],
                OutlineSummary [1, 2] "応用" 1 []
              ],
            OutlineSummary [2] "まとめ" 1 []
          ]

    it "同じタイトルでも位置ごとに別々に集計する" $ do
      summarizeOutline
        [ Node "概要" [Node "概要" []],
          Node "概要" []
        ]
        `shouldBe` Right
          [ OutlineSummary
              [1]
              "概要"
              2
              [OutlineSummary [1, 1] "概要" 1 []],
            OutlineSummary [2] "概要" 1 []
          ]

    it "空白だけのタイトルは有効とする" $ do
      summarizeOutline [Node " " []]
        `shouldBe` Right
          [OutlineSummary [1] " " 1 []]

    it "空タイトルの葉をその位置のエラーにする" $ do
      summarizeOutline
        [Node "親" [Node "有効" [], Node "" []]]
        `shouldBe` Left (EmptyTitle [1, 2])

    it "親子とも空タイトルなら先に処理する子のエラーを返す" $ do
      summarizeOutline [Node "" [Node "" []]]
        `shouldBe` Left (EmptyTitle [1, 1])

recordNode ::
  [Int] ->
  String ->
  [Recorded] ->
  Either OutlineError Recorded
recordNode path value children =
  Right (Recorded path value children)

rejectEmptyNode ::
  [Int] ->
  String ->
  [()] ->
  Either OutlineError ()
rejectEmptyNode path value _
  | null value = Left (EmptyTitle path)
  | otherwise = Right ()
