module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "mapMaybeForestBottomUpWithPathEither" $ do
    it "空の木ではdecideを使わず空の結果を返す" $ do
      mapMaybeForestBottomUpWithPathEither
        keepMarked
        ([] :: [Tree String])
        `shouldBe` Right []

    it "枝刈り後に残った子だけを親のdecideへ渡す" $ do
      mapMaybeForestBottomUpWithPathEither
        keepMarked
        [ Node
            "parent"
            [ Node "drop" [],
              Node "keep-child" []
            ]
        ]
        `shouldBe` Right
          [ Node
              ([1], "parent")
              [Node ([1, 2], "keep-child") []]
          ]

    it "残った子を判断材料にして未指定の親を残せる" $ do
      mapMaybeForestBottomUpWithPathEither
        keepMarked
        [Node "plain-parent" [Node "keep-leaf" []]]
        `shouldBe` Right
          [ Node
              ([1], "plain-parent")
              [Node ([1, 1], "keep-leaf") []]
          ]

    it "Nothingの親と、その下ですでに変換した子を取り除く" $ do
      mapMaybeForestBottomUpWithPathEither
        dropParent
        [ Node "drop-parent" [Node "keep-child" []],
          Node "keep-sibling" []
        ]
        `shouldBe` Right
          [Node ([2], "keep-sibling") []]

    it "枝刈り後も元入力上の兄弟番号をパスに使う" $ do
      mapMaybeForestBottomUpWithPathEither
        keepMarked
        [ Node "drop" [],
          Node "keep-B" [],
          Node "keep-C" []
        ]
        `shouldBe` Right
          [ Node ([2], "keep-B") [],
            Node ([3], "keep-C") []
          ]

    it "親より先に子のエラーを返す" $ do
      mapMaybeForestBottomUpWithPathEither
        rejectEmpty
        [Node "" [Node "" []]]
        `shouldBe` Left (EmptyCategoryName [1, 1])

    it "左の部分木のエラーで後続の兄弟を処理しない" $ do
      mapMaybeForestBottomUpWithPathEither
        rejectEmpty
        [ Node "A" [Node "" []],
          Node "" []
        ]
        `shouldBe` Left (EmptyCategoryName [1, 1])

  describe "selectedCategoryTree" $ do
    it "空のカテゴリー木を空の結果にする" $ do
      selectedCategoryTree [] `shouldBe` Right []

    it "選択された葉を残す" $ do
      selectedCategoryTree
        [Node (Category "Haskell" True) []]
        `shouldBe` Right [Node "Haskell" []]

    it "未選択で選択された子孫もない葉を取り除く" $ do
      selectedCategoryTree
        [Node (Category "雑記" False) []]
        `shouldBe` Right []

    it "選択された子孫へ至る未選択の祖先を残す" $ do
      selectedCategoryTree
        [ Node
            (Category "開発" False)
            [ Node (Category "Haskell" True) [],
              Node (Category "Rust" False) []
            ],
          Node (Category "雑記" False) []
        ]
        `shouldBe` Right
          [Node "開発" [Node "Haskell" []]]

    it "複数階層の未選択の祖先を残す" $ do
      selectedCategoryTree
        [ Node
            (Category "技術" False)
            [ Node
                (Category "言語" False)
                [Node (Category "Haskell" True) []]
            ]
        ]
        `shouldBe` Right
          [ Node
              "技術"
              [Node "言語" [Node "Haskell" []]]
          ]

    it "選択された親でも未選択の空の枝は残さない" $ do
      selectedCategoryTree
        [ Node
            (Category "開発" True)
            [ Node (Category "Haskell" True) [],
              Node (Category "Rust" False) []
            ]
        ]
        `shouldBe` Right
          [Node "開発" [Node "Haskell" []]]

    it "同じ名前でも別々の位置にある選択を保つ" $ do
      selectedCategoryTree
        [ Node (Category "言語" True) [],
          Node (Category "言語" True) []
        ]
        `shouldBe` Right
          [Node "言語" [], Node "言語" []]

    it "空白だけの名前は有効とする" $ do
      selectedCategoryTree
        [Node (Category " " True) []]
        `shouldBe` Right [Node " " []]

    it "空の名前を元入力上のパス付きエラーにする" $ do
      selectedCategoryTree
        [ Node (Category "開発" False)
            [ Node (Category "Rust" False) [],
              Node (Category "" True) []
            ]
        ]
        `shouldBe` Left (EmptyCategoryName [1, 2])

    it "取り除かれる未選択の部分木も名前を検証する" $ do
      selectedCategoryTree
        [ Node (Category "非表示" False)
            [Node (Category "" False) []]
        ]
        `shouldBe` Left (EmptyCategoryName [1, 1])

    it "親子とも空の名前なら子のエラーを先に返す" $ do
      selectedCategoryTree
        [ Node (Category "" False)
            [Node (Category "" False) []]
        ]
        `shouldBe` Left (EmptyCategoryName [1, 1])

keepMarked ::
  [Int] ->
  String ->
  [Tree ([Int], String)] ->
  Either CategoryError (Maybe ([Int], String))
keepMarked path value remainingChildren
  | take 4 value == "keep" || not (null remainingChildren) =
      Right (Just (path, value))
  | otherwise = Right Nothing

dropParent ::
  [Int] ->
  String ->
  [Tree ([Int], String)] ->
  Either CategoryError (Maybe ([Int], String))
dropParent path value _
  | value == "drop-parent" = Right Nothing
  | otherwise = Right (Just (path, value))

rejectEmpty ::
  [Int] ->
  String ->
  [Tree String] ->
  Either CategoryError (Maybe String)
rejectEmpty path value _
  | null value = Left (EmptyCategoryName path)
  | otherwise = Right (Just value)
