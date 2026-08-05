module Lib
  ( InventoryOperation,
    InventoryError (..),
    mkAddStock,
    mkRemoveStock,
    applyInventoryOperations,
  )
where

data InventoryOperation
  = AddStock Int
  | RemoveStock Int
  deriving (Eq, Show)

data InventoryError
  = QuantityMustBePositive Int
  | InitialStockMustNotBeNegative Int
  | InsufficientStock
      { operationIndex :: Int,
        requestedQuantity :: Int,
        availableStock :: Int
      }
  deriving (Eq, Show)

mkAddStock :: Int -> Either InventoryError InventoryOperation
mkAddStock qty
  | qty <= 0 =
      Left (QuantityMustBePositive qty)
  | otherwise =
      Right (AddStock qty)

mkRemoveStock :: Int -> Either InventoryError InventoryOperation
mkRemoveStock qty
  | qty <= 0 =
      Left (QuantityMustBePositive qty)
  | otherwise =
      Right (RemoveStock qty)

applyInventoryOperation ::
  Int ->
  Int ->
  InventoryOperation ->
  Either InventoryError Int
applyInventoryOperation index current op =
  case op of
    AddStock qty ->
      Right
        (current + qty)
    RemoveStock qty
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

applyInventoryOperationsFrom ::
  Int ->
  Int ->
  [InventoryOperation] ->
  Either InventoryError Int
applyInventoryOperationsFrom _ current [] = Right current
applyInventoryOperationsFrom index current (x : xs) =
  case applyInventoryOperation index current x of
    Left err ->
      Left err
    Right updated ->
      applyInventoryOperationsFrom (index + 1) updated xs

applyInventoryOperations ::
  Int ->
  [InventoryOperation] ->
  Either InventoryError Int
applyInventoryOperations initial ops
  | initial < 0 =
      Left (InitialStockMustNotBeNegative initial)
  | otherwise = applyInventoryOperationsFrom 1 initial ops
