module Lib
  ( Tree (..),
    OutlineError (..),
    mapForestWithPathEither,
    numberOutline,
  )
where

data Tree a
  = Node a [Tree a]
  deriving (Eq, Show)

data OutlineError
  = EmptyTitle [Int]
  deriving (Eq, Show)

mapForestWithPathEither ::
  ([Int] -> a -> Either err b) ->
  [Tree a] ->
  Either err [Tree b]
mapForestWithPathEither _ [] = Right []
mapForestWithPathEither func nodes = mapForest func [] 1 nodes
  where
    mapForest :: ([Int] -> a -> Either err b) ->
      [Int] -> Int -> [Tree a] ->
      Either err [Tree b]
    mapForest _ _ _ [] = Right []
    mapForest func parent index (x : xs) =
      case mapTree func parent index x of
        Left err -> Left err
        Right newX ->
          case mapForest func parent (index + 1) xs of
            Left err -> Left err
            Right newXs -> Right (newX : newXs)

    mapTree func parent index (Node val list) =
      let currentPath = parent ++ [index]
      in case func currentPath val of
        Left err -> Left err
        Right newVal ->
          case mapForest func currentPath 1 list of
            Left err -> Left err
            Right newChildren ->
              Right (Node newVal newChildren)

numberOutline ::
  [Tree String] ->
  Either OutlineError [Tree ([Int], String)]
numberOutline =
  mapForestWithPathEither attachPath
  where
    attachPath path title
      | null title = Left (EmptyTitle path)
      | otherwise = Right (path, title)
