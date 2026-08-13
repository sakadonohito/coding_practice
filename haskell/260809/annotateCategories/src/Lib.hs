module Lib
  ( Tree (..),
    AnnotationError (..),
    mapAccumForestWithContextEither,
    annotateCategories,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data AnnotationError
  = EmptyCategoryName
      { expectedNumber :: Int,
        ancestorBreadcrumbs :: [String]
      }
  deriving (Eq, Show)

mapAccumForestWithContextEither ::
  (context -> state -> a -> Either err (state, context, b)) ->
  context ->
  state ->
  [Tree a] ->
  Either err (state, [Tree b])
mapAccumForestWithContextEither _ _ index [] = Right (index, [])
mapAccumForestWithContextEither func parent index (x : xs) =
  case mapAccumTreeWithContextEither func parent index x of
    Left err -> Left err
    Right (newIndex, newNode) ->
      case mapAccumForestWithContextEither func parent newIndex xs of
        Left err -> Left err
        Right (finalIndex, newXs) -> Right (finalIndex, newNode : newXs)

mapAccumTreeWithContextEither ::
  (context -> state -> a -> Either err (state, context, b)) ->
  context ->
  state ->
  Tree a ->
  Either err (state, Tree b)
mapAccumTreeWithContextEither func parent index (Node val list) =
  case func parent index val of
    Left err -> Left err
    Right (nextIndex, newContext, newNode) ->
      case mapAccumForestWithContextEither func newContext nextIndex list of
        Left err -> Left err
        Right (finalIndex, finalChildren) ->
          Right (finalIndex, Node newNode finalChildren)

annotateCategories ::
  [Tree String] ->
  Either AnnotationError [Tree (Int, [String])]
annotateCategories forest =
  fmap snd
    (mapAccumForestWithContextEither annotate [] 1 forest)
  where
    annotate parentBreadcrumbs nextNumber name
      | null name =
          Left
            EmptyCategoryName
              { expectedNumber = nextNumber,
                ancestorBreadcrumbs = parentBreadcrumbs
              }
      | otherwise =
          let breadcrumbs = parentBreadcrumbs ++ [name]
           in Right
                ( nextNumber + 1,
                  breadcrumbs,
                  (nextNumber, breadcrumbs)
                )
