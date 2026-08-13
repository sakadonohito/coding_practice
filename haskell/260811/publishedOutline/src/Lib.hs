module Lib
  ( Tree (..),
    PublishState (..),
    OutlineItem (..),
    OutlineError (..),
    mapMaybeForestWithPathEither,
    publishedOutline,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data PublishState
  = Published
  | Draft
  deriving (Eq, Show)

data OutlineItem = OutlineItem
  { itemTitle :: String,
    publishState :: PublishState
  }
  deriving (Eq, Show)

data OutlineError
  = EmptyTitle [Int]
  deriving (Eq, Show)

mapMaybeForestWithPathEither ::
  ([Int] -> a -> Either err (Maybe b)) ->
  [Tree a] ->
  Either err [Tree b]
mapMaybeForestWithPathEither _ [] = Right []
mapMaybeForestWithPathEither transform nodes = mapForest transform [] 1 nodes
  where
    mapForest _ _ _ [] = Right []
    mapForest transform parentPath siblingNumber (tree : rest) =
      case mapTree transform parentPath siblingNumber tree of
        Left err -> Left err
        Right (Just newNode) ->
          case mapForest transform parentPath (siblingNumber + 1) rest of
            Left err -> Left err
            Right  newChildren -> Right (newNode : newChildren)
        Right Nothing ->
          case mapForest transform parentPath (siblingNumber + 1) rest of
            Left err -> Left err
            Right  newChildren -> Right newChildren

    mapTree transform parentPath siblingNumber (Node value children) =
      case transform currentPath value of
        Left err -> Left err
        Right Nothing -> Right Nothing
        Right (Just newValue) ->
          case mapForest transform currentPath 1 children of
            Left err -> Left err
            Right newChildren ->
              Right (Just (Node newValue newChildren))
      where
        currentPath = parentPath ++ [siblingNumber]

publishedOutline ::
  [Tree OutlineItem] ->
  Either OutlineError [Tree String]
publishedOutline =
  mapMaybeForestWithPathEither selectPublished
  where
    selectPublished path item
      | null (itemTitle item) = Left (EmptyTitle path)
      | publishState item == Published =
          Right (Just (itemTitle item))
      | otherwise = Right Nothing
