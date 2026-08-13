module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "mapAccumForestWithContextEither" $ do
    it "空のリストでは初期状態をそのまま返す" $ do
      mapAccumForestWithContextEither makeAnnotation [] 10 []
        `shouldBe` Right (10, [])

    it "子には親のstepが作った文脈を渡す" $ do
      mapAccumForestWithContextEither
        makeAnnotation
        ["開始前"]
        1
        [Node "親" [Node "子" []]]
        `shouldBe` Right
          ( 3,
            [ Node
                (1, ["開始前", "親"])
                [Node (2, ["開始前", "親", "子"]) []]
            ]
          )

    it "兄弟には前の兄弟の文脈を引き継がない" $ do
      mapAccumForestWithContextEither
        makeAnnotation
        []
        1
        [Node "A" [], Node "B" []]
        `shouldBe` Right
          ( 3,
            [ Node (1, ["A"]) [],
              Node (2, ["B"]) []
            ]
          )

    it "子孫で更新した状態は次の兄弟へ引き継ぐ" $ do
      mapAccumForestWithContextEither
        makeAnnotation
        []
        1
        [ Node "A" [Node "A-1" [Node "A-1-a" []]],
          Node "B" []
        ]
        `shouldBe` Right
          ( 5,
            [ Node
                (1, ["A"])
                [ Node
                    (2, ["A", "A-1"])
                    [Node (3, ["A", "A-1", "A-1-a"]) []]
                ],
              Node (4, ["B"]) []
            ]
          )

    it "stepが返した最初のエラーで処理を止める" $ do
      mapAccumForestWithContextEither
        makeAnnotation
        []
        1
        [ Node "親"
            [ Node "" [],
              Node "" []
            ],
          Node "" []
        ]
        `shouldBe` Left
          EmptyCategoryName
            { expectedNumber = 2,
              ancestorBreadcrumbs = ["親"]
            }

  describe "annotateCategories" $ do
    it "空のカテゴリー木を空の結果にする" $ do
      annotateCategories [] `shouldBe` Right []

    it "親・子・次の兄弟へ番号とパンくずを付ける" $ do
      annotateCategories
        [ Node
            "本"
            [ Node "技術書" [],
              Node "小説" []
            ],
          Node "音楽" []
        ]
        `shouldBe` Right
          [ Node
              (1, ["本"])
              [ Node (2, ["本", "技術書"]) [],
                Node (3, ["本", "小説"]) []
              ],
            Node (4, ["音楽"]) []
          ]

    it "同じ名前でも位置ごとに異なるパンくずを作る" $ do
      annotateCategories
        [ Node "本" [Node "新着" []],
          Node "音楽" [Node "新着" []]
        ]
        `shouldBe` Right
          [ Node (1, ["本"]) [Node (2, ["本", "新着"]) []],
            Node (3, ["音楽"]) [Node (4, ["音楽", "新着"]) []]
          ]

    it "空白だけの名前は有効とする" $ do
      annotateCategories [Node " " []]
        `shouldBe` Right [Node (1, [" "]) []]

    it "ルートの空名には番号1と空の祖先パンくずを付ける" $ do
      annotateCategories [Node "" []]
        `shouldBe` Left
          EmptyCategoryName
            { expectedNumber = 1,
              ancestorBreadcrumbs = []
            }

    it "深い子孫の後の空名には更新済み番号と親のパンくずを付ける" $ do
      annotateCategories
        [ Node
            "本"
            [ Node "技術書" [Node "Haskell" []],
              Node "" []
            ]
        ]
        `shouldBe` Left
          EmptyCategoryName
            { expectedNumber = 4,
              ancestorBreadcrumbs = ["本"]
            }

makeAnnotation ::
  [String] ->
  Int ->
  String ->
  Either AnnotationError (Int, [String], (Int, [String]))
makeAnnotation parentBreadcrumbs nextNumber name
  | null name =
      Left
        EmptyCategoryName
          { expectedNumber = nextNumber,
            ancestorBreadcrumbs = parentBreadcrumbs
          }
  | otherwise =
      let breadcrumbs = parentBreadcrumbs ++ [name]
       in Right
            ( nextNumber + 1,
              breadcrumbs,
              (nextNumber, breadcrumbs)
            )
