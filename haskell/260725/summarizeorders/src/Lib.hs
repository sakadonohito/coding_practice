module Lib
  ( OrderLine (..),
    OrderSummary (..),
    isValidOrderLine,
    addOrderLine,
    summarizeOrders,
  )
where

-- import Data.List (foldl')
{-
    The import of ‘Data.List’ is redundant
      except perhaps to import instances from ‘Data.List’
    To import instances alone, use: import Data.List()
   |
10 | import Data.List (foldl')
   | ^^^^^^^^^^^^^^^^^^^^^^^^^

-}

data OrderLine = OrderLine
  { unitPrice :: Int,
    quantity :: Int
  }
  deriving (Eq, Show)

data OrderSummary = OrderSummary
  { validLineCount :: Int,
    totalQuantity :: Int,
    totalAmount :: Int,
    invalidLineCount :: Int
  }
  deriving (Eq, Show)

{-
unitPrice >= 0
quantity > 0
-}
isValidOrderLine :: OrderLine -> Bool
isValidOrderLine OrderLine {unitPrice = price, quantity = qty} =
  -- if price >= 0 && qty > 0 then True else False
  price >= 0 && qty > 0

addOrderLine :: OrderSummary -> OrderLine -> OrderSummary
addOrderLine summary item
  | isValidOrderLine item =
      {- True
        validLineCount を1増やす
        totalQuantity に quantity を加える
        totalAmount に unitPrice × quantity を加える
      -}
      summary
        { validLineCount = validLineCount summary + 1,
          totalQuantity = totalQuantity summary + qty,
          totalAmount = totalAmount summary + (price * qty)
        }
  | otherwise =
      -- False: invalidLineCount を1増やす
      summary
        { invalidLineCount = invalidLineCount summary + 1
        }
  where
    price = unitPrice item
    qty = quantity item

{-
初期状態を外で定義しておいて、summarizeOrdersで使う方法もある。
この場合、関数内容がシンプルに見える。
emptyOrderSummary :: OrderSummary
emptyOrderSummary =
  OrderSummary
    { validLineCount = 0
    , totalQuantity = 0
    , totalAmount = 0
    , invalidLineCount = 0
    }
-}

summarizeOrders :: [OrderLine] -> OrderSummary
summarizeOrders list =
  -- 集計結果 -> 要素 -> 集計結果
  foldl'
    addOrderLine
    OrderSummary
      { validLineCount = 0,
        totalQuantity = 0,
        totalAmount = 0,
        invalidLineCount = 0
      }
    list
