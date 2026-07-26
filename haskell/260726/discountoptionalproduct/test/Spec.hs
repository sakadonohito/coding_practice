module Main (main) where

import Lib
  ( Product (..),
    applyDiscount,
    discountOptionalProduct,
    normalizeDiscountRate,
  )
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "normalizeDiscountRate" $ do
    it "0から100までの割引率はそのまま返す" $ do
      normalizeDiscountRate 20
        `shouldBe` 20

    it "境界値の0はそのまま返す" $ do
      normalizeDiscountRate 0
        `shouldBe` 0

    it "境界値の100はそのまま返す" $ do
      normalizeDiscountRate 100
        `shouldBe` 100

    it "負の割引率は0に補正する" $ do
      normalizeDiscountRate (-1)
        `shouldBe` 0

    it "大きな負数も0に補正する" $ do
      normalizeDiscountRate (-100)
        `shouldBe` 0

    it "100を超える割引率は100に補正する" $ do
      normalizeDiscountRate 101
        `shouldBe` 100

    it "非常に大きな割引率も100に補正する" $ do
      normalizeDiscountRate 1000
        `shouldBe` 100

  describe "applyDiscount" $ do
    it "商品価格に割引を適用する" $ do
      let item =
            Product
              { productName = "Keyboard",
                productPrice = 10000
              }

          expected =
            Product
              { productName = "Keyboard",
                productPrice = 8000
              }

      applyDiscount 20 item
        `shouldBe` expected

    it "割引率0では価格を変更しない" $ do
      let item =
            Product
              { productName = "Mouse",
                productPrice = 5000
              }

      applyDiscount 0 item
        `shouldBe` item

    it "割引率100では価格を0にする" $ do
      let item =
            Product
              { productName = "Monitor",
                productPrice = 30000
              }

          expected =
            Product
              { productName = "Monitor",
                productPrice = 0
              }

      applyDiscount 100 item
        `shouldBe` expected

    it "負の割引率は0として扱う" $ do
      let item =
            Product
              { productName = "Speaker",
                productPrice = 8000
              }

      applyDiscount (-20) item
        `shouldBe` item

    it "100を超える割引率は100として扱う" $ do
      let item =
            Product
              { productName = "Webcam",
                productPrice = 6000
              }

          expected =
            Product
              { productName = "Webcam",
                productPrice = 0
              }

      applyDiscount 150 item
        `shouldBe` expected

    it "割り切れない場合は整数除算した価格を返す" $ do
      let item =
            Product
              { productName = "Cable",
                productPrice = 999
              }

          expected =
            Product
              { productName = "Cable",
                productPrice = 899
              }

      applyDiscount 10 item
        `shouldBe` expected

    it "価格0の商品は割引後も価格0になる" $ do
      let item =
            Product
              { productName = "Free Sample",
                productPrice = 0
              }

      applyDiscount 50 item
        `shouldBe` item

    it "割引を適用しても商品名を変更しない" $ do
      let item =
            Product
              { productName = "Special Keyboard",
                productPrice = 12000
              }

      productName (applyDiscount 25 item)
        `shouldBe` "Special Keyboard"

  describe "discountOptionalProduct" $ do
    it "Justに入っている商品へ割引を適用する" $ do
      let item =
            Product
              { productName = "Keyboard",
                productPrice = 10000
              }

          expected =
            Just
              Product
                { productName = "Keyboard",
                  productPrice = 8000
                }

      discountOptionalProduct 20 (Just item)
        `shouldBe` expected

    it "Nothingには何もせずNothingを返す" $ do
      discountOptionalProduct 20 Nothing
        `shouldBe` Nothing

    it "Justの商品に割引率0を適用しても内容を変更しない" $ do
      let item =
            Product
              { productName = "Mouse",
                productPrice = 5000
              }

      discountOptionalProduct 0 (Just item)
        `shouldBe` Just item

    it "Justの商品に割引率100を適用すると価格を0にする" $ do
      let item =
            Product
              { productName = "Monitor",
                productPrice = 30000
              }

          expected =
            Just
              Product
                { productName = "Monitor",
                  productPrice = 0
                }

      discountOptionalProduct 100 (Just item)
        `shouldBe` expected

    it "Justの商品では不正な割引率も補正して適用する" $ do
      let item =
            Product
              { productName = "Webcam",
                productPrice = 6000
              }

          expected =
            Just
              Product
                { productName = "Webcam",
                  productPrice = 0
                }

      discountOptionalProduct 150 (Just item)
        `shouldBe` expected
