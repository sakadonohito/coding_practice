module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "spliceForestBottomUpWithPathEither" $ do
    it "空の森ではdecideを使わず空の結果を返す" $ do
      spliceForestBottomUpWithPathEither
        keepWithPath
        ([] :: [Tree String])
        `shouldBe` Right []

    it "差し替え済みの子だけを親のdecideへ渡す" $ do
      spliceForestBottomUpWithPathEither
        spliceMarked
        [ Node
            "parent"
            [ Node "remove" [],
              Node "keep-child" []
            ]
        ]
        `shouldBe` Right
          [ Node
              ([1], "parent")
              [Node ([1, 2], "keep-child") []]
          ]

    it "親だけを除き、処理済みの子を現在の階層へ繰り上げる" $ do
      spliceForestBottomUpWithPathEither
        spliceMarked
        [ Node
            "promote"
            [ Node "keep-A" [],
              Node "keep-B" []
            ],
          Node "keep-C" []
        ]
        `shouldBe` Right
          [ Node ([1, 1], "keep-A") [],
            Node ([1, 2], "keep-B") [],
            Node ([2], "keep-C") []
          ]

    it "1つの入力ノードを複数の木へ差し替えられる" $ do
      spliceForestBottomUpWithPathEither
        duplicateNode
        [Node "A" []]
        `shouldBe` Right
          [ Node ([1], "A-1") [],
            Node ([1], "A-2") []
          ]

    it "差し替え後も元入力上の兄弟番号をパスに使う" $ do
      spliceForestBottomUpWithPathEither
        spliceMarked
        [ Node "remove" [],
          Node "keep-B" []
        ]
        `shouldBe` Right
          [Node ([2], "keep-B") []]

    it "親より先に子のエラーを返す" $ do
      spliceForestBottomUpWithPathEither
        rejectEmpty
        [Node "" [Node "" []]]
        `shouldBe` Left (EmptyItemTitle [1, 1])

    it "左の部分木のエラーで後続の兄弟を処理しない" $ do
      spliceForestBottomUpWithPathEither
        rejectEmpty
        [ Node "A" [Node "" []],
          Node "" []
        ]
        `shouldBe` Left (EmptyItemTitle [1, 1])

  describe "buildNavigation" $ do
    it "空のナビゲーションを空の結果にする" $ do
      buildNavigation [] `shouldBe` Right []

    it "Keepの項目と処理済みの子を残す" $ do
      buildNavigation
        [ Node
            (NavigationItem "開発" Keep)
            [Node (NavigationItem "Haskell" Keep) []]
        ]
        `shouldBe` Right
          [Node "開発" [Node "Haskell" []]]

    it "RemoveSubtreeの項目は子ごと取り除く" $ do
      buildNavigation
        [ Node
            (NavigationItem "下書き" RemoveSubtree)
            [Node (NavigationItem "内部メモ" Keep) []],
          Node (NavigationItem "公開" Keep) []
        ]
        `shouldBe` Right [Node "公開" []]

    it "PromoteChildrenの子を現在の階層へ繰り上げる" $ do
      buildNavigation
        [ Node
            (NavigationItem "開発" PromoteChildren)
            [ Node (NavigationItem "Haskell" Keep) [],
              Node (NavigationItem "Rust" Keep) []
            ]
        ]
        `shouldBe` Right
          [Node "Haskell" [], Node "Rust" []]

    it "入れ子のPromoteChildrenでも子の順序を保つ" $ do
      buildNavigation
        [ Node
            (NavigationItem "技術" Keep)
            [ Node
                (NavigationItem "言語" PromoteChildren)
                [ Node (NavigationItem "Haskell" Keep) [],
                  Node (NavigationItem "Rust" Keep) []
                ],
              Node (NavigationItem "DB" Keep) []
            ]
        ]
        `shouldBe` Right
          [ Node
              "技術"
              [ Node "Haskell" [],
                Node "Rust" [],
                Node "DB" []
              ]
          ]

    it "子を持たないPromoteChildrenを空の結果にする" $ do
      buildNavigation
        [Node (NavigationItem "空のグループ" PromoteChildren) []]
        `shouldBe` Right []

    it "空白だけのタイトルは有効とする" $ do
      buildNavigation
        [Node (NavigationItem " " Keep) []]
        `shouldBe` Right [Node " " []]

    it "空タイトルを元入力上のパス付きエラーにする" $ do
      buildNavigation
        [ Node
            (NavigationItem "開発" Keep)
            [ Node (NavigationItem "Rust" Keep) [],
              Node (NavigationItem "" Keep) []
            ]
        ]
        `shouldBe` Left (EmptyItemTitle [1, 2])

    it "取り除かれる部分木の子も先に検証する" $ do
      buildNavigation
        [ Node
            (NavigationItem "非公開" RemoveSubtree)
            [Node (NavigationItem "" Keep) []]
        ]
        `shouldBe` Left (EmptyItemTitle [1, 1])

    it "親子とも空タイトルなら子のエラーを先に返す" $ do
      buildNavigation
        [ Node
            (NavigationItem "" PromoteChildren)
            [Node (NavigationItem "" Keep) []]
        ]
        `shouldBe` Left (EmptyItemTitle [1, 1])

keepWithPath ::
  [Int] ->
  String ->
  [Tree ([Int], String)] ->
  Either NavigationError [Tree ([Int], String)]
keepWithPath path value children =
  Right [Node (path, value) children]

spliceMarked ::
  [Int] ->
  String ->
  [Tree ([Int], String)] ->
  Either NavigationError [Tree ([Int], String)]
spliceMarked path value children
  | value == "remove" = Right []
  | value == "promote" = Right children
  | otherwise = Right [Node (path, value) children]

duplicateNode ::
  [Int] ->
  String ->
  [Tree ([Int], String)] ->
  Either NavigationError [Tree ([Int], String)]
duplicateNode path value _ =
  Right
    [ Node (path, value ++ "-1") [],
      Node (path, value ++ "-2") []
    ]

rejectEmpty ::
  [Int] ->
  String ->
  [Tree String] ->
  Either NavigationError [Tree String]
rejectEmpty path value children
  | null value = Left (EmptyItemTitle path)
  | otherwise = Right [Node value children]
