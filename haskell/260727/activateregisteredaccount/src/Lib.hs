module Lib
  ( Account (..),
    RegistrationError (..),
    RegistrationResult,
    validateAccount,
    activateAccount,
    activateRegisteredAccount,
  )
where

data Account = Account
  { accountName :: String,
    loginCount :: Int,
    isActive :: Bool
  }
  deriving (Eq, Show)

data RegistrationError
  = EmptyAccountName
  | NegativeLoginCount Int
  deriving (Eq, Show)

type RegistrationResult =
  Either RegistrationError Account

validateAccount ::
  Account ->
  RegistrationResult
validateAccount account
  | accountName account == "" =
      Left EmptyAccountName
  | loginCount account < 0 =
      Left (NegativeLoginCount (loginCount account))
  | otherwise =
      Right account

activateAccount ::
  Account ->
  Account
activateAccount account =
  account {isActive = True}

activateRegisteredAccount ::
  RegistrationResult ->
  RegistrationResult
activateRegisteredAccount result =
  fmap activateAccount result
