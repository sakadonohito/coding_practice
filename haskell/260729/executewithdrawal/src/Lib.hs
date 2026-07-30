module Lib
  ( Account (..),
    TransferAmount,
    TransferError (..),
    WithdrawalResult,
    validateTransferAmount,
    transferAmountValue,
    withdraw,
    executeWithdrawal,
  )
where

data Account = Account
  { accountId :: String,
    balance :: Int
  }
  deriving (Eq, Show)

newtype TransferAmount
  = TransferAmount Int
  deriving (Eq, Show)

data TransferError
  = AmountMustBePositive Int
  | InsufficientBalance
      { requestedAmount :: Int,
        availableBalance :: Int
      }
  deriving (Eq, Show)

type WithdrawalResult =
  Either TransferError Account

{-
validateTransferAmount 0
-- Left (AmountMustBePositive 0)

validateTransferAmount (-100)
-- Left (AmountMustBePositive (-100))
-}
validateTransferAmount ::
  Int ->
  Either TransferError TransferAmount
validateTransferAmount amount
  | amount <= 0 =
      Left (AmountMustBePositive amount)
  | otherwise =
      Right (TransferAmount amount)

-- TransferAmount の中にある整数値を取り出します。
transferAmountValue :: TransferAmount -> Int
transferAmountValue (TransferAmount amount) = amount

-- 出金
withdraw ::
  Account ->
  TransferAmount ->
  WithdrawalResult
withdraw account (TransferAmount amount)
  | updatedBalance < 0 =
      Left
        InsufficientBalance
          { requestedAmount = amount,
            availableBalance = currentBalance
          }
  | otherwise =
      Right
        account {balance = updatedBalance}
  where
    currentBalance = balance account
    updatedBalance = currentBalance - amount

{-
未検証のInt
  ↓ validateTransferAmount
TransferAmountまたは検証エラー
  ↓ withdraw
更新後のAccountまたは残高不足エラー
-}
executeWithdrawal ::
  Account ->
  Int ->
  WithdrawalResult
executeWithdrawal account requested =
  validateTransferAmount requested >>= withdraw account
