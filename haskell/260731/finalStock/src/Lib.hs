module Lib
  ( InventoryOperation (..),
    InventoryError (..),
    InventorySummary (..),
    emptyInventorySummary,
    applyInventoryOperation,
    applyInventoryOperations,
    finalStock,
  )
where

data InventoryOperation
  = AddStock Int
  | RemoveStock Int
  deriving (Eq, Show)

data InventoryError
  = QuantityMustBePositive
      { operationIndex :: Int,
        invalidQuantity :: Int
      }
  | InsufficientStock
      { operationIndex :: Int,
        requestedQuantity :: Int,
        availableStock :: Int
      }
  deriving (Eq, Show)

data InventorySummary = InventorySummary
  { currentStock :: Int,
    processedOperationCount :: Int,
    inventoryErrors :: [InventoryError]
  }
  deriving (Eq, Show)

emptyInventorySummary ::
  Int ->
  InventorySummary
emptyInventorySummary input =
  InventorySummary
    { currentStock = initial,
      processedOperationCount = 0,
      inventoryErrors = []
    }
  where
    initial = if input > 0 then input else 0

applyInventoryOperation ::
  InventorySummary ->
  InventoryOperation ->
  InventorySummary
applyInventoryOperation pre op =
  case op of
    AddStock qty
      | qty <= 0 ->
          pre
            { processedOperationCount = nextIndex,
              inventoryErrors =
                ( QuantityMustBePositive
                    { operationIndex = nextIndex,
                      invalidQuantity = qty
                    }
                )
                  : inventoryErrors pre
            }
      | otherwise ->
          pre
            { currentStock = current + qty,
              processedOperationCount = nextIndex
            }
    RemoveStock qty
      | qty <= 0 ->
          pre
            { processedOperationCount = nextIndex,
              inventoryErrors =
                ( QuantityMustBePositive
                    { operationIndex = nextIndex,
                      invalidQuantity = qty
                    }
                )
                  : inventoryErrors pre
            }
      | current < qty ->
          pre
            { processedOperationCount = nextIndex,
              inventoryErrors =
                ( InsufficientStock
                    { operationIndex = nextIndex,
                      requestedQuantity = qty,
                      availableStock = current
                    }
                )
                  : inventoryErrors pre
            }
      | otherwise ->
          pre
            { currentStock = current - qty,
              processedOperationCount = nextIndex
            }
  where
    opCount = processedOperationCount pre
    nextIndex = opCount + 1
    current = currentStock pre

applyInventoryOperations ::
  Int ->
  [InventoryOperation] ->
  InventorySummary
applyInventoryOperations initial [] = emptyInventorySummary initial
applyInventoryOperations initial operations =
  let result =
        foldl'
          applyInventoryOperation
          (emptyInventorySummary initial)
          operations
   in result {inventoryErrors = reverse (inventoryErrors result)}

finalStock ::
  InventorySummary ->
  Int
finalStock summary = currentStock summary
