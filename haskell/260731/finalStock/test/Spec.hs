module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "emptyInventorySummary" $ do
    it "指定された初期在庫から未処理の集計状態を作る" $ do
      emptyInventorySummary 10
        `shouldBe` InventorySummary
          { currentStock = 10,
            processedOperationCount = 0,
            inventoryErrors = []
          }

    it "初期在庫0もそのまま保持する" $ do
      emptyInventorySummary 0
        `shouldBe` InventorySummary
          { currentStock = 0,
            processedOperationCount = 0,
            inventoryErrors = []
          }

  describe "applyInventoryOperation" $ do
    it "正の数量を入庫すると在庫が増える" $ do
      let initial =
            emptyInventorySummary 10

          expected =
            InventorySummary
              { currentStock = 15,
                processedOperationCount = 1,
                inventoryErrors = []
              }

      applyInventoryOperation initial (AddStock 5)
        `shouldBe` expected

    it "正の数量を出庫すると在庫が減る" $ do
      let initial =
            emptyInventorySummary 10

          expected =
            InventorySummary
              { currentStock = 7,
                processedOperationCount = 1,
                inventoryErrors = []
              }

      applyInventoryOperation initial (RemoveStock 3)
        `shouldBe` expected

    it "現在在庫と同数を出庫すると在庫0になる" $ do
      let initial =
            emptyInventorySummary 10

          expected =
            InventorySummary
              { currentStock = 0,
                processedOperationCount = 1,
                inventoryErrors = []
              }

      applyInventoryOperation initial (RemoveStock 10)
        `shouldBe` expected

    it "数量0の入庫では在庫を変更せずエラーを追加する" $ do
      let initial =
            emptyInventorySummary 10

          expected =
            InventorySummary
              { currentStock = 10,
                processedOperationCount = 1,
                inventoryErrors =
                  [ QuantityMustBePositive
                      { operationIndex = 1,
                        invalidQuantity = 0
                      }
                  ]
              }

      applyInventoryOperation initial (AddStock 0)
        `shouldBe` expected

    it "負数の出庫では在庫を変更せずエラーを追加する" $ do
      let initial =
            emptyInventorySummary 10

          expected =
            InventorySummary
              { currentStock = 10,
                processedOperationCount = 1,
                inventoryErrors =
                  [ QuantityMustBePositive
                      { operationIndex = 1,
                        invalidQuantity = -2
                      }
                  ]
              }

      applyInventoryOperation initial (RemoveStock (-2))
        `shouldBe` expected

    it "現在在庫を超える出庫では在庫不足エラーを追加する" $ do
      let initial =
            emptyInventorySummary 10

          expected =
            InventorySummary
              { currentStock = 10,
                processedOperationCount = 1,
                inventoryErrors =
                  [ InsufficientStock
                      { operationIndex = 1,
                        requestedQuantity = 11,
                        availableStock = 10
                      }
                  ]
              }

      applyInventoryOperation initial (RemoveStock 11)
        `shouldBe` expected

    it "処理済み件数を基にエラーの操作番号を設定する" $ do
      let initial =
            InventorySummary
              { currentStock = 5,
                processedOperationCount = 3,
                inventoryErrors = []
              }

          expected =
            InventorySummary
              { currentStock = 5,
                processedOperationCount = 4,
                inventoryErrors =
                  [ InsufficientStock
                      { operationIndex = 4,
                        requestedQuantity = 8,
                        availableStock = 5
                      }
                  ]
              }

      applyInventoryOperation initial (RemoveStock 8)
        `shouldBe` expected

    it "既存エラーを残したまま新しいエラーを先頭へ追加する" $ do
      let existingError =
            QuantityMustBePositive
              { operationIndex = 1,
                invalidQuantity = 0
              }

          initial =
            InventorySummary
              { currentStock = 5,
                processedOperationCount = 1,
                inventoryErrors = [existingError]
              }

          newError =
            InsufficientStock
              { operationIndex = 2,
                requestedQuantity = 8,
                availableStock = 5
              }

          expected =
            InventorySummary
              { currentStock = 5,
                processedOperationCount = 2,
                inventoryErrors =
                  [newError, existingError]
              }

      applyInventoryOperation initial (RemoveStock 8)
        `shouldBe` expected

  describe "applyInventoryOperations" $ do
    it "空の操作リストでは初期状態をそのまま返す" $ do
      applyInventoryOperations 10 []
        `shouldBe` InventorySummary
          { currentStock = 10,
            processedOperationCount = 0,
            inventoryErrors = []
          }

    it "複数の正常操作を入力順に適用する" $ do
      let operations =
            [ AddStock 5,
              RemoveStock 3,
              AddStock 2
            ]

          expected =
            InventorySummary
              { currentStock = 14,
                processedOperationCount = 3,
                inventoryErrors = []
              }

      applyInventoryOperations 10 operations
        `shouldBe` expected

    it "前の操作結果を次の操作へ引き継ぐ" $ do
      let operations =
            [ AddStock 5,
              RemoveStock 12
            ]

          expected =
            InventorySummary
              { currentStock = 3,
                processedOperationCount = 2,
                inventoryErrors = []
              }

      applyInventoryOperations 10 operations
        `shouldBe` expected

    it "在庫不足の操作後も後続の入庫を処理する" $ do
      let operations =
            [ RemoveStock 20,
              AddStock 5
            ]

          expected =
            InventorySummary
              { currentStock = 15,
                processedOperationCount = 2,
                inventoryErrors =
                  [ InsufficientStock
                      { operationIndex = 1,
                        requestedQuantity = 20,
                        availableStock = 10
                      }
                  ]
              }

      applyInventoryOperations 10 operations
        `shouldBe` expected

    it "不正数量の操作後も後続の正常操作を処理する" $ do
      let operations =
            [ AddStock 0,
              AddStock 4,
              RemoveStock 3
            ]

          expected =
            InventorySummary
              { currentStock = 11,
                processedOperationCount = 3,
                inventoryErrors =
                  [ QuantityMustBePositive
                      { operationIndex = 1,
                        invalidQuantity = 0
                      }
                  ]
              }

      applyInventoryOperations 10 operations
        `shouldBe` expected

    it "複数のエラーを発生順に保持する" $ do
      let operations =
            [ AddStock 0,
              RemoveStock 20,
              RemoveStock (-1)
            ]

          expected =
            InventorySummary
              { currentStock = 10,
                processedOperationCount = 3,
                inventoryErrors =
                  [ QuantityMustBePositive
                      { operationIndex = 1,
                        invalidQuantity = 0
                      },
                    InsufficientStock
                      { operationIndex = 2,
                        requestedQuantity = 20,
                        availableStock = 10
                      },
                    QuantityMustBePositive
                      { operationIndex = 3,
                        invalidQuantity = -1
                      }
                  ]
              }

      applyInventoryOperations 10 operations
        `shouldBe` expected

    it "エラーになった操作でも処理済み件数へ含める" $ do
      let operations =
            [ AddStock 0,
              RemoveStock 50,
              AddStock 1
            ]

      processedOperationCount
        (applyInventoryOperations 10 operations)
        `shouldBe` 3

    it "操作の途中時点の在庫を在庫不足エラーへ記録する" $ do
      let operations =
            [ AddStock 5,
              RemoveStock 20
            ]

          expectedError =
            InsufficientStock
              { operationIndex = 2,
                requestedQuantity = 20,
                availableStock = 15
              }

      inventoryErrors
        (applyInventoryOperations 10 operations)
        `shouldBe` [expectedError]

    it "初期在庫0から入庫と出庫を処理できる" $ do
      let operations =
            [ AddStock 3,
              RemoveStock 3
            ]

          expected =
            InventorySummary
              { currentStock = 0,
                processedOperationCount = 2,
                inventoryErrors = []
              }

      applyInventoryOperations 0 operations
        `shouldBe` expected

  describe "finalStock" $ do
    it "集計結果から現在在庫を返す" $ do
      let summary =
            InventorySummary
              { currentStock = 42,
                processedOperationCount = 3,
                inventoryErrors = []
              }

      finalStock summary
        `shouldBe` 42

    it "操作結果から最終在庫を取得できる" $ do
      let operations =
            [ AddStock 10,
              RemoveStock 4
            ]

      finalStock
        (applyInventoryOperations 5 operations)
        `shouldBe` 11
