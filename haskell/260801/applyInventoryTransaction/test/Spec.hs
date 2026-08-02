module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "applyInventoryTransaction" $ do
    it "複数の正常な操作を入力順に適用し最終在庫を返す" $ do
      let operations =
            [ AddStock 5,
              RemoveStock 3,
              AddStock 2
            ]

      applyInventoryTransaction 10 operations
        `shouldBe` Right 14

    it "前の操作で増えた在庫を次の出庫に利用する" $ do
      let operations =
            [ AddStock 5,
              RemoveStock 12
            ]

      applyInventoryTransaction 10 operations
        `shouldBe` Right 3

    it "現在在庫と同数を出庫すると在庫0になる" $ do
      applyInventoryTransaction 10 [RemoveStock 10]
        `shouldBe` Right 0

    it "空の操作リストでは初期在庫をそのまま返す" $ do
      applyInventoryTransaction 10 []
        `shouldBe` Right 10

    it "初期在庫0を有効として扱う" $ do
      applyInventoryTransaction 0 [AddStock 3, RemoveStock 3]
        `shouldBe` Right 0

    it "負の初期在庫なら操作を処理せずエラーを返す" $ do
      applyInventoryTransaction (-1) [AddStock 5]
        `shouldBe` Left (InitialStockMustNotBeNegative (-1))

    it "数量0の入庫を操作番号付きのエラーにする" $ do
      applyInventoryTransaction 10 [AddStock 0]
        `shouldBe` Left
          QuantityMustBePositive
            { operationIndex = 1,
              invalidQuantity = 0
            }

    it "負数の出庫を操作番号付きのエラーにする" $ do
      applyInventoryTransaction 10 [RemoveStock (-2)]
        `shouldBe` Left
          QuantityMustBePositive
            { operationIndex = 1,
              invalidQuantity = -2
            }

    it "在庫を超える出庫では操作直前の在庫を記録する" $ do
      let operations =
            [ AddStock 5,
              RemoveStock 16
            ]

      applyInventoryTransaction 10 operations
        `shouldBe` Left
          InsufficientStock
            { operationIndex = 2,
              requestedQuantity = 16,
              availableStock = 15
            }

    it "成功した操作の後で失敗しても正しい操作番号を返す" $ do
      let operations =
            [ AddStock 1,
              RemoveStock 1,
              AddStock 0
            ]

      applyInventoryTransaction 10 operations
        `shouldBe` Left
          QuantityMustBePositive
            { operationIndex = 3,
              invalidQuantity = 0
            }

    it "複数の不正操作があっても入力順で最初のエラーだけを返す" $ do
      let operations =
            [ RemoveStock 20,
              AddStock 0,
              RemoveStock (-1)
            ]

      applyInventoryTransaction 10 operations
        `shouldBe` Left
          InsufficientStock
            { operationIndex = 1,
              requestedQuantity = 20,
              availableStock = 10
            }

    it "初期在庫のエラーを操作のエラーより先に返す" $ do
      applyInventoryTransaction (-5) [AddStock 0]
        `shouldBe` Left (InitialStockMustNotBeNegative (-5))
