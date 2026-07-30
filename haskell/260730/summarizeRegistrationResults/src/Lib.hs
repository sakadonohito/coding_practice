module Lib
  ( Account (..),
    RegistrationError (..),
    RegistrationResult,
    BatchResult (..),
    emptyBatchResult,
    addRegistrationResult,
    summarizeRegistrationResults,
  )
where

data Account = Account
  { accountName :: String,
    isActive :: Bool
  }
  deriving (Eq, Show)

data RegistrationError
  = EmptyAccountName
  | AccountNameTooShort Int
  | AccountNameAlreadyExists String
  deriving (Eq, Show)

type RegistrationResult =
  Either RegistrationError Account

data BatchResult = BatchResult
  { successfulAccounts :: [Account],
    registrationErrors :: [RegistrationError]
  }
  deriving (Eq, Show)

emptyBatchResult ::
  BatchResult
emptyBatchResult =
  BatchResult
    { successfulAccounts = [],
      registrationErrors = []
    }

addRegistrationResult ::
  RegistrationResult ->
  BatchResult ->
  BatchResult
addRegistrationResult result summary =
  case result of
    Left err ->
      summary {registrationErrors = err : (registrationErrors summary)}
    Right account ->
      summary {successfulAccounts = account : (successfulAccounts summary)}

summarizeRegistrationResults ::
  [RegistrationResult] ->
  BatchResult
summarizeRegistrationResults results =
  foldr
    addRegistrationResult
    emptyBatchResult
    results

{-
addRegistrationResult
    1件の登録結果を集計へ加える

emptyBatchResult
    まだ何も集計していない状態

results
    登録結果のリスト
-}
