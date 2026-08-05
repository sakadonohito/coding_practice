module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "mkAddStock" $ do
    it "正の数量から入庫操作を作れる" $ do
      case mkAddStock 5 of
        Left err ->
          expectationFailure ("予期しないエラー: " ++ show err)
        Right operation ->
          applyInventoryOperations 10 [operation]
            `shouldBe` Right 15

    it "数量0から入庫操作を作れない" $ do
      mkAddStock 0
        `shouldBe` Left (QuantityMustBePositive 0)

    it "負の数量から入庫操作を作れない" $ do
      mkAddStock (-1)
        `shouldBe` Left (QuantityMustBePositive (-1))

  describe "mkRemoveStock" $ do
    it "正の数量から出庫操作を作れる" $ do
      case mkRemoveStock 4 of
        Left err ->
          expectationFailure ("予期しないエラー: " ++ show err)
        Right operation ->
          applyInventoryOperations 10 [operation]
            `shouldBe` Right 6

    it "数量0から出庫操作を作れない" $ do
      mkRemoveStock 0
        `shouldBe` Left (QuantityMustBePositive 0)

    it "負の数量から出庫操作を作れない" $ do
      mkRemoveStock (-2)
        `shouldBe` Left (QuantityMustBePositive (-2))

  describe "applyInventoryOperations" $ do
    it "複数の有効な操作を入力順に適用する" $ do
      case (mkAddStock 5, mkRemoveStock 3, mkAddStock 2) of
        (Right addFive, Right removeThree, Right addTwo) ->
          applyInventoryOperations
            10
            [addFive, removeThree, addTwo]
            `shouldBe` Right 14
        unexpected ->
          expectationFailure
            ("テストデータの生成に失敗: " ++ show unexpected)

    it "前の入庫結果を次の出庫へ引き継ぐ" $ do
      case (mkAddStock 5, mkRemoveStock 12) of
        (Right addFive, Right removeTwelve) ->
          applyInventoryOperations
            10
            [addFive, removeTwelve]
            `shouldBe` Right 3
        unexpected ->
          expectationFailure
            ("テストデータの生成に失敗: " ++ show unexpected)

    it "現在在庫と同数を出庫すると在庫0になる" $ do
      case mkRemoveStock 10 of
        Left err ->
          expectationFailure ("予期しないエラー: " ++ show err)
        Right operation ->
          applyInventoryOperations 10 [operation]
            `shouldBe` Right 0

    it "空の操作リストでは初期在庫をそのまま返す" $ do
      applyInventoryOperations 10 []
        `shouldBe` Right 10

    it "初期在庫0を有効として扱う" $ do
      applyInventoryOperations 0 []
        `shouldBe` Right 0

    it "負の初期在庫を操作より先にエラーにする" $ do
      case mkAddStock 5 of
        Left err ->
          expectationFailure ("予期しないエラー: " ++ show err)
        Right operation ->
          applyInventoryOperations (-1) [operation]
            `shouldBe` Left (InitialStockMustNotBeNegative (-1))

    it "在庫を超える出庫では操作直前の在庫を記録する" $ do
      case (mkAddStock 5, mkRemoveStock 16) of
        (Right addFive, Right removeSixteen) ->
          applyInventoryOperations
            10
            [addFive, removeSixteen]
            `shouldBe` Left
              InsufficientStock
                { operationIndex = 2,
                  requestedQuantity = 16,
                  availableStock = 15
                }
        unexpected ->
          expectationFailure
            ("テストデータの生成に失敗: " ++ show unexpected)

    it "最初の在庫不足で止まり後続操作を適用しない" $ do
      case (mkRemoveStock 11, mkAddStock 100) of
        (Right removeEleven, Right addHundred) ->
          applyInventoryOperations
            10
            [removeEleven, addHundred]
            `shouldBe` Left
              InsufficientStock
                { operationIndex = 1,
                  requestedQuantity = 11,
                  availableStock = 10
                }
        unexpected ->
          expectationFailure
            ("テストデータの生成に失敗: " ++ show unexpected)
