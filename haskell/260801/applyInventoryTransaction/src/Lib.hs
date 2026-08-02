module Lib
  ( InventoryOperation (..),
    InventoryError (..),
    applyInventoryTransaction,
  )
where

data InventoryOperation
  = AddStock Int
  | RemoveStock Int
  deriving (Eq, Show)

data InventoryError
  = InitialStockMustNotBeNegative Int
  | QuantityMustBePositive
      { operationIndex :: Int,
        invalidQuantity :: Int
      }
  | InsufficientStock
      { operationIndex :: Int,
        requestedQuantity :: Int,
        availableStock :: Int
      }
  deriving (Eq, Show)

applyInventoryOperation ::
  Int ->
  Int ->
  InventoryOperation ->
  Either InventoryError Int
applyInventoryOperation index current op =
  case op of
    AddStock qty
      | qty <= 0 ->
          Left
            QuantityMustBePositive
              { operationIndex = index,
                invalidQuantity = qty
              }
      | otherwise ->
          Right
            (current + qty)
    RemoveStock qty
      | qty <= 0 ->
          Left
            QuantityMustBePositive
              { operationIndex = index,
                invalidQuantity = qty
              }
      | current < qty ->
          Left
            InsufficientStock
              { operationIndex = index,
                requestedQuantity = qty,
                availableStock = current
              }
      | otherwise ->
          Right
            (current - qty)

applyInventoryOperations ::
  Int ->
  Int ->
  [InventoryOperation] ->
  Either InventoryError Int
applyInventoryOperations _ current [] = Right current
applyInventoryOperations index current (x : xs) =
  case applyInventoryOperation index current x of
    Left err ->
      Left err
    Right updated ->
      applyInventoryOperations (index + 1) updated xs

applyInventoryTransaction ::
  Int ->
  [InventoryOperation] ->
  Either InventoryError Int
applyInventoryTransaction initial ops
  | initial < 0 =
      Left (InitialStockMustNotBeNegative initial)
  | ops == [] =
      Right initial
  | otherwise = applyInventoryOperations 1 initial ops
