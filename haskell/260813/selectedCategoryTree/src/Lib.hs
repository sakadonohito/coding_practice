module Lib
  ( Tree (..),
    Category (..),
    CategoryError (..),
    mapMaybeForestBottomUpWithPathEither,
    selectedCategoryTree,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data Category = Category
  { categoryName :: String,
    isSelected :: Bool
  }
  deriving (Eq, Show)

data CategoryError
  = EmptyCategoryName [Int]
  deriving (Eq, Show)
mapMaybeForestBottomUpWithPathEither ::
  ([Int] -> a -> [Tree b] -> Either err (Maybe b)) ->
  [Tree a] ->
  Either err [Tree b]
mapMaybeForestBottomUpWithPathEither decide nodes = mapForest [] 1 nodes
  where
    mapForest _ _ [] = Right []
    mapForest parentPath siblingNumber (tree : rest) =
      case mapTree parentPath siblingNumber tree of
        Left err -> Left err
        Right (Just newValue) ->
          case mapForest parentPath (siblingNumber + 1) rest of
            Left err -> Left err
            Right newSiblings -> Right (newValue : newSiblings)
        Right Nothing ->
          case mapForest parentPath (siblingNumber + 1) rest of
            Left err -> Left err
            Right newValue -> Right newValue

    mapTree parentPath siblingNumber (Node value children) =
      case mapForest currentPath 1 children of
        Left err -> Left err
        Right prunedChildren ->
          case decide currentPath value prunedChildren of
            Left err -> Left err
            Right Nothing -> Right Nothing
            Right (Just newValue) ->
              Right (Just (Node newValue prunedChildren))
      where
        currentPath = parentPath ++ [siblingNumber]

selectedCategoryTree ::
  [Tree Category] ->
  Either CategoryError [Tree String]
selectedCategoryTree =
  mapMaybeForestBottomUpWithPathEither selectCategory
  where
    selectCategory path category remainingChildren
      | null (categoryName category) =
          Left (EmptyCategoryName path)
      | isSelected category || not (null remainingChildren) =
          Right (Just (categoryName category))
      | otherwise = Right Nothing
