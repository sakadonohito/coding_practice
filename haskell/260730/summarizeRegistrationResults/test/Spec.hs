module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "emptyBatchResult" $ do
    it "成功アカウントとエラーがどちらも空の集計結果を返す" $ do
      emptyBatchResult
        `shouldBe` BatchResult
          { successfulAccounts = [],
            registrationErrors = []
          }

  describe "addRegistrationResult" $ do
    it "Rightのアカウントを成功一覧へ追加する" $ do
      let account =
            Account
              { accountName = "alice",
                isActive = False
              }

          expected =
            BatchResult
              { successfulAccounts = [account],
                registrationErrors = []
              }

      addRegistrationResult
        (Right account)
        emptyBatchResult
        `shouldBe` expected

    it "Leftのエラーをエラー一覧へ追加する" $ do
      let expected =
            BatchResult
              { successfulAccounts = [],
                registrationErrors =
                  [EmptyAccountName]
              }

      addRegistrationResult
        (Left EmptyAccountName)
        emptyBatchResult
        `shouldBe` expected

    it "Rightを追加しても既存のエラー一覧を変更しない" $ do
      let account =
            Account
              { accountName = "alice",
                isActive = False
              }

          initial =
            BatchResult
              { successfulAccounts = [],
                registrationErrors =
                  [EmptyAccountName]
              }

          expected =
            BatchResult
              { successfulAccounts = [account],
                registrationErrors =
                  [EmptyAccountName]
              }

      addRegistrationResult
        (Right account)
        initial
        `shouldBe` expected

    it "Leftを追加しても既存の成功一覧を変更しない" $ do
      let account =
            Account
              { accountName = "alice",
                isActive = False
              }

          initial =
            BatchResult
              { successfulAccounts = [account],
                registrationErrors = []
              }

          expected =
            BatchResult
              { successfulAccounts = [account],
                registrationErrors =
                  [AccountNameTooShort 2]
              }

      addRegistrationResult
        (Left (AccountNameTooShort 2))
        initial
        `shouldBe` expected

    it "Rightの値を既存の成功一覧の先頭へ追加する" $ do
      let alice =
            Account
              { accountName = "alice",
                isActive = False
              }

          bob =
            Account
              { accountName = "bob",
                isActive = True
              }

          initial =
            BatchResult
              { successfulAccounts = [bob],
                registrationErrors = []
              }

          expected =
            BatchResult
              { successfulAccounts = [alice, bob],
                registrationErrors = []
              }

      addRegistrationResult
        (Right alice)
        initial
        `shouldBe` expected

    it "Leftの値を既存のエラー一覧の先頭へ追加する" $ do
      let initial =
            BatchResult
              { successfulAccounts = [],
                registrationErrors =
                  [AccountNameTooShort 2]
              }

          expected =
            BatchResult
              { successfulAccounts = [],
                registrationErrors =
                  [ EmptyAccountName,
                    AccountNameTooShort 2
                  ]
              }

      addRegistrationResult
        (Left EmptyAccountName)
        initial
        `shouldBe` expected

  describe "summarizeRegistrationResults" $ do
    it "空リストから空の集計結果を返す" $ do
      summarizeRegistrationResults []
        `shouldBe` emptyBatchResult

    it "成功結果だけを成功一覧へ集める" $ do
      let alice =
            Account
              { accountName = "alice",
                isActive = False
              }

          bob =
            Account
              { accountName = "bob",
                isActive = True
              }

          results =
            [ Right alice,
              Right bob
            ]

          expected =
            BatchResult
              { successfulAccounts = [alice, bob],
                registrationErrors = []
              }

      summarizeRegistrationResults results
        `shouldBe` expected

    it "失敗結果だけをエラー一覧へ集める" $ do
      let results =
            [ Left EmptyAccountName,
              Left (AccountNameTooShort 2),
              Left
                (AccountNameAlreadyExists "alice")
            ]

          expected =
            BatchResult
              { successfulAccounts = [],
                registrationErrors =
                  [ EmptyAccountName,
                    AccountNameTooShort 2,
                    AccountNameAlreadyExists "alice"
                  ]
              }

      summarizeRegistrationResults results
        `shouldBe` expected

    it "成功と失敗が混在する結果をそれぞれ集計する" $ do
      let alice =
            Account
              { accountName = "alice",
                isActive = False
              }

          bob =
            Account
              { accountName = "bob",
                isActive = True
              }

          results =
            [ Right alice,
              Left EmptyAccountName,
              Right bob,
              Left (AccountNameTooShort 2)
            ]

          expected =
            BatchResult
              { successfulAccounts = [alice, bob],
                registrationErrors =
                  [ EmptyAccountName,
                    AccountNameTooShort 2
                  ]
              }

      summarizeRegistrationResults results
        `shouldBe` expected

    it "成功アカウントの出現順を維持する" $ do
      let first =
            Account
              { accountName = "first",
                isActive = False
              }

          second =
            Account
              { accountName = "second",
                isActive = False
              }

          third =
            Account
              { accountName = "third",
                isActive = False
              }

          results =
            [ Right first,
              Left EmptyAccountName,
              Right second,
              Right third
            ]

      successfulAccounts
        (summarizeRegistrationResults results)
        `shouldBe` [first, second, third]

    it "エラーの出現順を維持する" $ do
      let results =
            [ Left EmptyAccountName,
              Right
                Account
                  { accountName = "alice",
                    isActive = False
                  },
              Left (AccountNameTooShort 1),
              Left
                (AccountNameAlreadyExists "bob")
            ]

      registrationErrors
        (summarizeRegistrationResults results)
        `shouldBe` [ EmptyAccountName,
                     AccountNameTooShort 1,
                     AccountNameAlreadyExists "bob"
                   ]

    it "1件だけの成功結果を集計できる" $ do
      let account =
            Account
              { accountName = "single",
                isActive = False
              }

          expected =
            BatchResult
              { successfulAccounts = [account],
                registrationErrors = []
              }

      summarizeRegistrationResults [Right account]
        `shouldBe` expected

    it "1件だけの失敗結果を集計できる" $ do
      let expected =
            BatchResult
              { successfulAccounts = [],
                registrationErrors =
                  [AccountNameTooShort 2]
              }

      summarizeRegistrationResults
        [Left (AccountNameTooShort 2)]
        `shouldBe` expected
