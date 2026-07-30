module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "validateTransferAmount" $ do
    it "正の金額を検証済みの出金額として返す" $ do
      fmap
        transferAmountValue
        (validateTransferAmount 500)
        `shouldBe` Right 500

    it "最小の正数1を有効とする" $ do
      fmap
        transferAmountValue
        (validateTransferAmount 1)
        `shouldBe` Right 1

    it "0をエラーにする" $ do
      validateTransferAmount 0
        `shouldBe` Left (AmountMustBePositive 0)

    it "負数を入力値を含むエラーにする" $ do
      validateTransferAmount (-1)
        `shouldBe` Left (AmountMustBePositive (-1))

    it "大きな負数も入力値を含むエラーにする" $ do
      validateTransferAmount (-10000)
        `shouldBe` Left (AmountMustBePositive (-10000))

  describe "transferAmountValue" $ do
    it "検証済みの出金額から整数値を取り出す" $ do
      case validateTransferAmount 750 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          transferAmountValue validAmount
            `shouldBe` 750

  describe "withdraw" $ do
    it "残高から検証済みの金額を引く" $ do
      let account =
            Account
              { accountId = "account-001",
                balance = 5000
              }

          expected =
            Right
              Account
                { accountId = "account-001",
                  balance = 3500
                }

      case validateTransferAmount 1500 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          withdraw account validAmount
            `shouldBe` expected

    it "残高と同額を出金すると残高0になる" $ do
      let account =
            Account
              { accountId = "account-002",
                balance = 2000
              }

          expected =
            Right
              Account
                { accountId = "account-002",
                  balance = 0
                }

      case validateTransferAmount 2000 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          withdraw account validAmount
            `shouldBe` expected

    it "残高を1だけ下回る金額を出金できる" $ do
      let account =
            Account
              { accountId = "account-003",
                balance = 1000
              }

          expected =
            Right
              Account
                { accountId = "account-003",
                  balance = 1
                }

      case validateTransferAmount 999 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          withdraw account validAmount
            `shouldBe` expected

    it "残高を超える金額なら残高不足エラーを返す" $ do
      let account =
            Account
              { accountId = "account-004",
                balance = 1000
              }

          expected =
            Left
              InsufficientBalance
                { requestedAmount = 1001,
                  availableBalance = 1000
                }

      case validateTransferAmount 1001 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          withdraw account validAmount
            `shouldBe` expected

    it "残高不足でも元の口座IDを変更する処理は行わない" $ do
      let account =
            Account
              { accountId = "account-005",
                balance = 100
              }

          expected =
            Left
              InsufficientBalance
                { requestedAmount = 500,
                  availableBalance = 100
                }

      case validateTransferAmount 500 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          withdraw account validAmount
            `shouldBe` expected

    it "出金後も口座IDを変更しない" $ do
      let account =
            Account
              { accountId = "account-006",
                balance = 3000
              }

      case validateTransferAmount 1000 of
        Left err ->
          expectationFailure
            ("unexpected validation error: " ++ show err)
        Right validAmount ->
          fmap
            accountId
            (withdraw account validAmount)
            `shouldBe` Right "account-006"

  describe "executeWithdrawal" $ do
    it "正しい入力額なら検証してから出金する" $ do
      let account =
            Account
              { accountId = "account-101",
                balance = 10000
              }

          expected =
            Right
              Account
                { accountId = "account-101",
                  balance = 7500
                }

      executeWithdrawal account 2500
        `shouldBe` expected

    it "入力額0なら検証エラーを返す" $ do
      let account =
            Account
              { accountId = "account-102",
                balance = 10000
              }

      executeWithdrawal account 0
        `shouldBe` Left (AmountMustBePositive 0)

    it "負の入力額なら検証エラーを返す" $ do
      let account =
            Account
              { accountId = "account-103",
                balance = 10000
              }

      executeWithdrawal account (-500)
        `shouldBe` Left (AmountMustBePositive (-500))

    it "正数でも残高を超える場合は残高不足エラーを返す" $ do
      let account =
            Account
              { accountId = "account-104",
                balance = 2000
              }

          expected =
            Left
              InsufficientBalance
                { requestedAmount = 3000,
                  availableBalance = 2000
                }

      executeWithdrawal account 3000
        `shouldBe` expected

    it "残高と同じ金額なら出金できる" $ do
      let account =
            Account
              { accountId = "account-105",
                balance = 800
              }

          expected =
            Right
              Account
                { accountId = "account-105",
                  balance = 0
                }

      executeWithdrawal account 800
        `shouldBe` expected

    it "入力検証の失敗を残高不足より先に返す" $ do
      let account =
            Account
              { accountId = "account-106",
                balance = 0
              }

      executeWithdrawal account 0
        `shouldBe` Left (AmountMustBePositive 0)
