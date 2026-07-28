module Lib
  ( Account (..),
    RegistrationError (..),
    RegistrationResult,
    ValidAccountName (..),
    validateAccountName,
    createAccount,
    registerAccount,
  )
where

newtype ValidAccountName
  = ValidAccountName String
  deriving (Eq, Show)

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

validateAccountName ::
  String ->
  Either RegistrationError ValidAccountName
validateAccountName name
  | name == "" =
      Left EmptyAccountName
  | length name < 3 =
      Left (AccountNameTooShort (length name))
  | otherwise =
      Right (ValidAccountName name)

createAccount ::
  [String] ->
  ValidAccountName ->
  RegistrationResult
createAccount existingNames (ValidAccountName validName)
  | validName `elem` existingNames =
      Left (AccountNameAlreadyExists validName)
  | otherwise =
      Right
        Account {accountName = validName, isActive = False}

registerAccount ::
  [String] ->
  String ->
  RegistrationResult
registerAccount existingNames inputName =
  validateAccountName inputName >>= createAccount existingNames
