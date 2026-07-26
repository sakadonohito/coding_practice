module Lib
  ( Product (..),
    normalizeDiscountRate,
    applyDiscount,
    discountOptionalProduct,
  )
where

data Product = Product
  { productName :: String,
    productPrice :: Int
  }
  deriving (Eq, Show)

{-
normalizeDiscountRate (-10) == 0
normalizeDiscountRate 20 == 20
normalizeDiscountRate 120 == 100
-}
normalizeDiscountRate :: Int -> Int
normalizeDiscountRate r
  | r < 0 = 0
  | 100 < r = 100
  | otherwise = r

{-
10000 × (100 - 20) ÷ 100
= 8000

20 10000
20
10000 * ((100 - 20) / 100)
10000 * (80 / 100)
10000 * 0.8
8000
-}
applyDiscount :: Int -> Product -> Product
applyDiscount rate product =
  let r = normalizeDiscountRate rate
      p = ((productPrice product) * (100 - r)) `div` 100
   in product {productPrice = p}

discountOptionalProduct ::
  Int ->
  Maybe Product ->
  Maybe Product
discountOptionalProduct discountRate maybeProduct =
  fmap (applyDiscount discountRate) maybeProduct
