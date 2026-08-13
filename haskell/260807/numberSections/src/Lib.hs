module Lib
  ( Section (..),
    NumberedSection (..),
    NumberingError (..),
    numberSections,
  )
where

data Section
  = Section String [Section]
  deriving (Eq, Show)

data NumberedSection
  = NumberedSection Int String [NumberedSection]
  deriving (Eq, Show)

data NumberingError
  = EmptySectionTitle Int
  deriving (Eq, Show)

numberSections ::
  [Section] ->
  Either NumberingError [NumberedSection]
numberSections sections =
  case numberingSections 1 sections of
    Left err -> Left err
    Right (_, numbered) -> Right numbered
  where
    numberingSections :: Int -> [Section] -> Either NumberingError (Int, [NumberedSection])
    numberingSections index [] = Right (index, [])
    numberingSections index (x : xs) =
      case numbering index x of
        Left err -> Left err
        Right (next, numbered) ->
          case numberingSections next xs of
            Left err -> Left err
            Right (finalIndex, numberedXs) ->
              Right (finalIndex, (numbered : numberedXs))

    numbering :: Int -> Section -> Either NumberingError (Int, NumberedSection)
    numbering index (Section title children)
      | null title = Left (EmptySectionTitle index)
      | otherwise = case numberingSections (index + 1) children of
          Left err -> Left err
          Right (next, numbered) ->
            Right (next, NumberedSection index title numbered)
