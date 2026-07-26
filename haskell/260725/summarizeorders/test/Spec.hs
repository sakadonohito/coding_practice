module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "isValidOrderLine" $ do
    it "単価が0以上かつ数量が1以上なら有効と判定する" $ do
      let orderLine =
            OrderLine
              { unitPrice = 500
              , quantity = 2
              }

      isValidOrderLine orderLine
        `shouldBe` True

    it "単価が0でも数量が1以上なら有効と判定する" $ do
      let orderLine =
            OrderLine
              { unitPrice = 0
              , quantity = 1
              }

      isValidOrderLine orderLine
        `shouldBe` True

    it "単価が負数なら無効と判定する" $ do
      let orderLine =
            OrderLine
              { unitPrice = -1
              , quantity = 2
              }

      isValidOrderLine orderLine
        `shouldBe` False

    it "数量が0なら無効と判定する" $ do
      let orderLine =
            OrderLine
              { unitPrice = 500
              , quantity = 0
              }

      isValidOrderLine orderLine
        `shouldBe` False

    it "数量が負数なら無効と判定する" $ do
      let orderLine =
            OrderLine
              { unitPrice = 500
              , quantity = -1
              }

      isValidOrderLine orderLine
        `shouldBe` False

  describe "addOrderLine" $ do
    it "有効な明細を集計結果へ反映する" $ do
      let initialSummary =
            OrderSummary
              { validLineCount = 0
              , totalQuantity = 0
              , totalAmount = 0
              , invalidLineCount = 0
              }

          orderLine =
            OrderLine
              { unitPrice = 500
              , quantity = 3
              }

          expected =
            OrderSummary
              { validLineCount = 1
              , totalQuantity = 3
              , totalAmount = 1500
              , invalidLineCount = 0
              }

      addOrderLine initialSummary orderLine
        `shouldBe` expected

    it "有効な明細を既存の集計結果へ加算する" $ do
      let initialSummary =
            OrderSummary
              { validLineCount = 2
              , totalQuantity = 5
              , totalAmount = 3000
              , invalidLineCount = 1
              }

          orderLine =
            OrderLine
              { unitPrice = 400
              , quantity = 2
              }

          expected =
            OrderSummary
              { validLineCount = 3
              , totalQuantity = 7
              , totalAmount = 3800
              , invalidLineCount = 1
              }

      addOrderLine initialSummary orderLine
        `shouldBe` expected

    it "単価が0の有効な明細は件数と数量だけを加算する" $ do
      let initialSummary =
            OrderSummary
              { validLineCount = 0
              , totalQuantity = 0
              , totalAmount = 0
              , invalidLineCount = 0
              }

          orderLine =
            OrderLine
              { unitPrice = 0
              , quantity = 3
              }

          expected =
            OrderSummary
              { validLineCount = 1
              , totalQuantity = 3
              , totalAmount = 0
              , invalidLineCount = 0
              }

      addOrderLine initialSummary orderLine
        `shouldBe` expected

    it "無効な明細では無効件数だけを増やす" $ do
      let initialSummary =
            OrderSummary
              { validLineCount = 2
              , totalQuantity = 5
              , totalAmount = 3000
              , invalidLineCount = 1
              }

          orderLine =
            OrderLine
              { unitPrice = -100
              , quantity = 2
              }

          expected =
            OrderSummary
              { validLineCount = 2
              , totalQuantity = 5
              , totalAmount = 3000
              , invalidLineCount = 2
              }

      addOrderLine initialSummary orderLine
        `shouldBe` expected

  describe "summarizeOrders" $ do
    it "空のリストからすべて0の集計結果を返す" $ do
      let expected =
            OrderSummary
              { validLineCount = 0
              , totalQuantity = 0
              , totalAmount = 0
              , invalidLineCount = 0
              }

      summarizeOrders []
        `shouldBe` expected

    it "有効な明細1件を集計する" $ do
      let orderLines =
            [ OrderLine
                { unitPrice = 500
                , quantity = 2
                }
            ]

          expected =
            OrderSummary
              { validLineCount = 1
              , totalQuantity = 2
              , totalAmount = 1000
              , invalidLineCount = 0
              }

      summarizeOrders orderLines
        `shouldBe` expected

    it "複数の有効な明細を集計する" $ do
      let orderLines =
            [ OrderLine
                { unitPrice = 500
                , quantity = 2
                }
            , OrderLine
                { unitPrice = 300
                , quantity = 4
                }
            ]

          expected =
            OrderSummary
              { validLineCount = 2
              , totalQuantity = 6
              , totalAmount = 2200
              , invalidLineCount = 0
              }

      summarizeOrders orderLines
        `shouldBe` expected

    it "有効な明細と無効な明細を分けて集計する" $ do
      let orderLines =
            [ OrderLine
                { unitPrice = 500
                , quantity = 2
                }
            , OrderLine
                { unitPrice = -100
                , quantity = 3
                }
            , OrderLine
                { unitPrice = 300
                , quantity = 0
                }
            , OrderLine
                { unitPrice = 200
                , quantity = 4
                }
            ]

          expected =
            OrderSummary
              { validLineCount = 2
              , totalQuantity = 6
              , totalAmount = 1800
              , invalidLineCount = 2
              }

      summarizeOrders orderLines
        `shouldBe` expected

    it "すべての明細が無効なら合計値を増やさない" $ do
      let orderLines =
            [ OrderLine
                { unitPrice = -1
                , quantity = 2
                }
            , OrderLine
                { unitPrice = 300
                , quantity = 0
                }
            , OrderLine
                { unitPrice = 100
                , quantity = -3
                }
            ]

          expected =
            OrderSummary
              { validLineCount = 0
              , totalQuantity = 0
              , totalAmount = 0
              , invalidLineCount = 3
              }

      summarizeOrders orderLines
        `shouldBe` expected

    it "単価0の明細を有効な明細として集計する" $ do
      let orderLines =
            [ OrderLine
                { unitPrice = 0
                , quantity = 5
                }
            ]

          expected =
            OrderSummary
              { validLineCount = 1
              , totalQuantity = 5
              , totalAmount = 0
              , invalidLineCount = 0
              }

      summarizeOrders orderLines
        `shouldBe` expected
