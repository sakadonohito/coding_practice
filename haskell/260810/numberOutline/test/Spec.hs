module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "mapForestWithPathEither" $ do
    it "空の木では変換結果も空になる" $ do
      mapForestWithPathEither keepPath ([] :: [Tree String])
        `shouldBe` Right []

    it "ルートの兄弟を1から順に数える" $ do
      mapForestWithPathEither
        keepPath
        [Node "A" [], Node "B" [], Node "C" []]
        `shouldBe` Right
          [ Node ([1], "A") [],
            Node ([2], "B") [],
            Node ([3], "C") []
          ]

    it "子の兄弟番号を各段で1から数え直す" $ do
      mapForestWithPathEither
        keepPath
        [ Node "A"
            [ Node "A-1" [],
              Node "A-2" []
            ],
          Node "B"
            [Node "B-1" []]
        ]
        `shouldBe` Right
          [ Node
              ([1], "A")
              [ Node ([1, 1], "A-1") [],
                Node ([1, 2], "A-2") []
              ],
            Node
              ([2], "B")
              [Node ([2, 1], "B-1") []]
          ]

    it "深い子孫の番号が後続の兄弟番号へ漏れない" $ do
      mapForestWithPathEither
        keepPath
        [ Node "A"
            [Node "A-1" [Node "A-1-a" []]],
          Node "B" []
        ]
        `shouldBe` Right
          [ Node
              ([1], "A")
              [ Node
                  ([1, 1], "A-1")
                  [Node ([1, 1, 1], "A-1-a") []]
              ],
            Node ([2], "B") []
          ]

    it "変換関数が位置を使って値の意味を決められる" $ do
      -- コンパイルエラーが出るので型シグネチャを追加
      let depth :: [Int] -> String -> Either OutlineError (Int, String)
          depth path value = Right (length path, value)

      mapForestWithPathEither
        depth
        [Node "親" [Node "子" [Node "孫" []]]]
        `shouldBe` Right
          [ Node
              (1, "親")
              [ Node
                  (2, "子")
                  [Node (3, "孫") []]
              ]
          ]

    it "深さ優先・先行順で最初のエラーを返す" $ do
      mapForestWithPathEither
        rejectEmpty
        [ Node "A"
            [ Node "" [],
              Node "" []
            ],
          Node "" []
        ]
        `shouldBe` Left (EmptyTitle [1, 1])

  describe "numberOutline" $ do
    it "空の目次を空の結果にする" $ do
      numberOutline [] `shouldBe` Right []

    it "階層番号と元のタイトルを各ノードへ保存する" $ do
      numberOutline
        [ Node "はじめに" [],
          Node "本文"
            [ Node "基本" [],
              Node "応用" []
            ],
          Node "まとめ" []
        ]
        `shouldBe` Right
          [ Node ([1], "はじめに") [],
            Node
              ([2], "本文")
              [ Node ([2, 1], "基本") [],
                Node ([2, 2], "応用") []
              ],
            Node ([3], "まとめ") []
          ]

    it "同じタイトルでも位置ごとに別々の階層番号を付ける" $ do
      numberOutline
        [ Node "概要" [Node "概要" []],
          Node "概要" []
        ]
        `shouldBe` Right
          [ Node ([1], "概要") [Node ([1, 1], "概要") []],
            Node ([2], "概要") []
          ]

    it "空白だけのタイトルは有効とする" $ do
      numberOutline [Node " " []]
        `shouldBe` Right [Node ([1], " ") []]

    it "ルートの空タイトルへ正しい位置を付けて失敗する" $ do
      numberOutline [Node "有効" [], Node "" []]
        `shouldBe` Left (EmptyTitle [2])

    it "深い位置の空タイトルへ完全な階層番号を付けて失敗する" $ do
      numberOutline
        [ Node "第1部"
            [ Node "第1章" [],
              Node "第2章"
                [Node "" []]
            ]
        ]
        `shouldBe` Left (EmptyTitle [1, 2, 1])

keepPath ::
  [Int] ->
  String ->
  Either OutlineError ([Int], String)
keepPath path value = Right (path, value)

rejectEmpty ::
  [Int] ->
  String ->
  Either OutlineError String
rejectEmpty path value
  | null value = Left (EmptyTitle path)
  | otherwise = Right value
