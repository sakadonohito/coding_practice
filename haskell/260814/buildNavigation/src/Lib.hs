module Lib
  ( Tree (..),
    EntryMode (..),
    NavigationItem (..),
    NavigationError (..),
    spliceForestBottomUpWithPathEither,
    buildNavigation,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data EntryMode
  = Keep
  | RemoveSubtree
  | PromoteChildren
  deriving (Eq, Show)

data NavigationItem = NavigationItem
  { itemTitle :: String,
    entryMode :: EntryMode
  }
  deriving (Eq, Show)

data NavigationError
  = EmptyItemTitle [Int]
  deriving (Eq, Show)

spliceForestBottomUpWithPathEither ::
  ([Int] -> a -> [Tree b] -> Either err [Tree b]) ->
  [Tree a] ->
  Either err [Tree b]
spliceForestBottomUpWithPathEither decide nodes = spliceForest [] 1 nodes
  where
    spliceForest _ _ [] = Right []
    spliceForest parentPath siblingNumber (tree : rest) =
      case spliceTree parentPath siblingNumber tree of
        Left err -> Left err
        Right spliced ->
          case spliceForest parentPath (siblingNumber + 1) rest of
            Left err -> Left err
            Right splicedSiblings -> Right (spliced ++ splicedSiblings)

    spliceTree parentPath siblingNumber (Node value children) =
      case spliceForest currentPath 1 children of
        Left err -> Left err
        Right splicedChildren ->
          decide currentPath value splicedChildren
      where
        currentPath = parentPath ++ [siblingNumber]

buildNavigation ::
  [Tree NavigationItem] ->
  Either NavigationError [Tree String]
buildNavigation =
  spliceForestBottomUpWithPathEither decide
  where
    decide path item splicedChildren
      | null (itemTitle item) =
          Left (EmptyItemTitle path)
      | otherwise =
          case entryMode item of
            Keep ->
              Right [Node (itemTitle item) splicedChildren]
            RemoveSubtree -> Right []
            PromoteChildren -> Right splicedChildren
