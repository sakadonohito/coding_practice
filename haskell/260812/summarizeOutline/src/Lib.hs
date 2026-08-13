module Lib
  ( Tree (..),
    OutlineSummary (..),
    OutlineError (..),
    foldForestBottomUpWithPathEither,
    summarizeOutline,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data OutlineSummary = OutlineSummary
  { summaryPath :: [Int],
    summaryTitle :: String,
    subtreeSize :: Int,
    childSummaries :: [OutlineSummary]
  }
  deriving (Eq, Show)

data OutlineError
  = EmptyTitle [Int]
  deriving (Eq, Show)

foldForestBottomUpWithPathEither ::
  ([Int] -> a -> [b] -> Either err b) ->
  [Tree a] ->
  Either err [b]
foldForestBottomUpWithPathEither combine nodes = foldForest [] 1 nodes
  where
    foldForest _ _ [] = Right []
    foldForest parentPath siblingNumber (tree : rest) =
      case foldTree parentPath siblingNumber tree of
        Left err -> Left err
        Right combined ->
          case foldForest parentPath (siblingNumber + 1) rest of
            Left err -> Left err
            Right combinedSiblings -> Right (combined : combinedSiblings)

    foldTree parentPath siblingNumber (Node value children) =
      case foldForest currentPath 1 children of
        Left err -> Left err
        Right combinedChildren ->
          combine currentPath value combinedChildren
      where
        currentPath = parentPath ++ [siblingNumber]

summarizeOutline ::
  [Tree String] ->
  Either OutlineError [OutlineSummary]
summarizeOutline =
  foldForestBottomUpWithPathEither makeSummary
  where
    makeSummary path title children
      | null title = Left (EmptyTitle path)
      | otherwise =
          Right
            OutlineSummary
              { summaryPath = path,
                summaryTitle = title,
                subtreeSize = 1 + sum (map subtreeSize children),
                childSummaries = children
              }
