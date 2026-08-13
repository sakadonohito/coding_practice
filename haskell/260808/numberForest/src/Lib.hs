module Lib
  ( Tree (..),
    NumberingError (..),
    mapAccumForestEither,
    numberForest,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data NumberingError
  = EmptyLabel Int
  deriving (Eq, Show)

mapAccumForestEither ::
  (state -> a -> Either err (state, b)) ->
  state ->
  [Tree a] ->
  Either err (state, [Tree b])
mapAccumForestEither _ state [] = Right (state, [])
mapAccumForestEither func state (x : xs) =
  case mapAccumTreeEither func state x of
    Left err -> Left err
    Right (next, newX) -> case mapAccumForestEither func next xs of
      Left err -> Left err
      Right (final, newXs) -> Right (final, newX : newXs)

mapAccumTreeEither ::
  (state -> a -> Either err (state, b)) ->
  state ->
  Tree a ->
  Either err (state, Tree b)
mapAccumTreeEither func state (Node val children) =
  case func state val of
    Left err -> Left err
    Right (stateAfterVal, newVal) ->
      case mapAccumForestEither func stateAfterVal children of
        Left err -> Left err
        Right (stateAfterChildren, newChildren) ->
          Right (stateAfterChildren, Node newVal newChildren)

numberForest ::
  [Tree String] ->
  Either NumberingError [Tree (Int, String)]
numberForest forest =
  fmap snd (mapAccumForestEither numberLabel 1 forest)
  where
    numberLabel nextNumber label
      | null label = Left (EmptyLabel nextNumber)
      | otherwise =
          Right
            ( nextNumber + 1,
              (nextNumber, label)
            )
