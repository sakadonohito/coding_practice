module Lib
  ( Person (..),
    ImportError (..),
    ImportResult,
    ImportSummary (..),
    addImportResult,
    summarizeImports,
  )
where

data Person = Person
  { personName :: String,
    personAge :: Int
  }
  deriving (Eq, Show)

data ImportError
  = EmptyName
  | InvalidAge Int
  deriving (Eq, Show)

type ImportResult = Either ImportError Person

data ImportSummary = ImportSummary
  { importedPeople :: [Person],
    importErrors :: [ImportError]
  }
  deriving (Eq, Show)

addImportResult ::
  ImportResult ->
  ImportSummary ->
  ImportSummary
addImportResult result summary = case result of
  Left err ->
    summary
      { importErrors = err : importErrors summary
      }
  Right person ->
    summary
      { importedPeople = person : importedPeople summary
      }

summarizeImports :: [ImportResult] -> ImportSummary
summarizeImports results = foldr addImportResult ImportSummary {importedPeople = [], importErrors = []} results
