module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "mapMaybeForestWithPathEither" $ do
    it "空の木では変換結果も空になる" $ do
      mapMaybeForestWithPathEither keepWithPath ([] :: [Tree String])
        `shouldBe` Right []

    it "Justの値へ変換し、元の親子関係を保つ" $ do
      mapMaybeForestWithPathEither
        keepWithPath
        [Node "親" [Node "子" []]]
        `shouldBe` Right
          [Node ([1], "親") [Node ([1, 1], "子") []]]

    it "Nothingのノードとその子孫を丸ごと除外する" $ do
      mapMaybeForestWithPathEither
        skipMarked
        [ Node "skip" [Node "残してはいけない" []],
          Node "表示" []
        ]
        `shouldBe` Right [Node ([2], "表示") []]

    it "除外後の兄弟にも元入力上の番号を渡す" $ do
      mapMaybeForestWithPathEither
        skipMarked
        [ Node "skip" [],
          Node "B" [],
          Node "C" []
        ]
        `shouldBe` Right
          [ Node ([2], "B") [],
            Node ([3], "C") []
          ]

    it "残した親では子の兄弟番号を1から数える" $ do
      mapMaybeForestWithPathEither
        skipMarked
        [ Node
            "親"
            [ Node "skip" [],
              Node "子" []
            ]
        ]
        `shouldBe` Right
          [Node ([1], "親") [Node ([1, 2], "子") []]]

    it "深さ優先・先行順で最初のエラーを返す" $ do
      mapMaybeForestWithPathEither
        rejectEmpty
        [ Node "親"
            [ Node "" [],
              Node "" []
            ],
          Node "" []
        ]
        `shouldBe` Left (EmptyTitle [1, 1])

    it "除外した部分木の子は処理しない" $ do
      mapMaybeForestWithPathEither
        skipOrRejectEmpty
        [ Node "skip" [Node "" []],
          Node "表示" []
        ]
        `shouldBe` Right [Node "表示" []]

  describe "publishedOutline" $ do
    it "公開済みの節をタイトルへ変換して残す" $ do
      publishedOutline
        [ Node
            (OutlineItem "本文" Published)
            [Node (OutlineItem "基本" Published) []],
          Node (OutlineItem "まとめ" Published) []
        ]
        `shouldBe` Right
          [ Node "本文" [Node "基本" []],
            Node "まとめ" []
          ]

    it "下書きの節をその子孫ごと除外する" $ do
      publishedOutline
        [ Node
            (OutlineItem "内部メモ" Draft)
            [Node (OutlineItem "公開予定" Published) []],
          Node (OutlineItem "概要" Published) []
        ]
        `shouldBe` Right [Node "概要" []]

    it "すべて下書きなら空の結果を返す" $ do
      publishedOutline
        [ Node (OutlineItem "A" Draft) [],
          Node (OutlineItem "B" Draft) []
        ]
        `shouldBe` Right []

    it "空タイトルは公開状態より先にエラーにする" $ do
      publishedOutline
        [Node (OutlineItem "" Draft) []]
        `shouldBe` Left (EmptyTitle [1])

    it "公開済みの深い空タイトルへ元入力上のパスを付ける" $ do
      publishedOutline
        [ Node
            (OutlineItem "本文" Published)
            [ Node (OutlineItem "下書き" Draft) [],
              Node (OutlineItem "" Published) []
            ]
        ]
        `shouldBe` Left (EmptyTitle [1, 2])

    it "除外された祖先の中にある空タイトルは調べない" $ do
      publishedOutline
        [ Node
            (OutlineItem "下書き" Draft)
            [Node (OutlineItem "" Published) []],
          Node (OutlineItem "公開" Published) []
        ]
        `shouldBe` Right [Node "公開" []]

    it "空白だけのタイトルは有効とする" $ do
      publishedOutline
        [Node (OutlineItem " " Published) []]
        `shouldBe` Right [Node " " []]

keepWithPath ::
  [Int] ->
  String ->
  Either OutlineError (Maybe ([Int], String))
keepWithPath path value = Right (Just (path, value))

skipMarked ::
  [Int] ->
  String ->
  Either OutlineError (Maybe ([Int], String))
skipMarked _ "skip" = Right Nothing
skipMarked path value = Right (Just (path, value))

rejectEmpty ::
  [Int] ->
  String ->
  Either OutlineError (Maybe String)
rejectEmpty path value
  | null value = Left (EmptyTitle path)
  | otherwise = Right (Just value)

skipOrRejectEmpty ::
  [Int] ->
  String ->
  Either OutlineError (Maybe String)
skipOrRejectEmpty _ "skip" = Right Nothing
skipOrRejectEmpty path value
  | null value = Left (EmptyTitle path)
  | otherwise = Right (Just value)
