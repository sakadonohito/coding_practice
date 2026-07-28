module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "validateAccount" $ do
    it "有効なアカウントをRightで返す" $ do
      let account =
            Account
              { accountName = "alice"
              , loginCount = 0
              , isActive = False
              }

      validateAccount account
        `shouldBe` Right account

    it "有効化済みのアカウントもRightで返す" $ do
      let account =
            Account
              { accountName = "bob"
              , loginCount = 10
              , isActive = True
              }

      validateAccount account
        `shouldBe` Right account

    it "空のアカウント名をエラーにする" $ do
      let account =
            Account
              { accountName = ""
              , loginCount = 0
              , isActive = False
              }

      validateAccount account
        `shouldBe` Left EmptyAccountName

    it "負のログイン回数をエラーにする" $ do
      let account =
            Account
              { accountName = "alice"
              , loginCount = -1
              , isActive = False
              }

      validateAccount account
        `shouldBe` Left (NegativeLoginCount (-1))

    it "大きな負数も実際の値を含むエラーにする" $ do
      let account =
            Account
              { accountName = "alice"
              , loginCount = -100
              , isActive = False
              }

      validateAccount account
        `shouldBe` Left (NegativeLoginCount (-100))

    it "名前とログイン回数の両方が不正なら名前のエラーを優先する" $ do
      let account =
            Account
              { accountName = ""
              , loginCount = -1
              , isActive = False
              }

      validateAccount account
        `shouldBe` Left EmptyAccountName

    it "ログイン回数0は有効な境界値として扱う" $ do
      let account =
            Account
              { accountName = "zero-login"
              , loginCount = 0
              , isActive = False
              }

      validateAccount account
        `shouldBe` Right account

  describe "activateAccount" $ do
    it "無効なアカウントを有効化する" $ do
      let account =
            Account
              { accountName = "alice"
              , loginCount = 3
              , isActive = False
              }

          expected =
            Account
              { accountName = "alice"
              , loginCount = 3
              , isActive = True
              }

      activateAccount account
        `shouldBe` expected

    it "既に有効なアカウントへ適用しても有効なまま返す" $ do
      let account =
            Account
              { accountName = "bob"
              , loginCount = 5
              , isActive = True
              }

      activateAccount account
        `shouldBe` account

    it "アカウント名を変更しない" $ do
      let account =
            Account
              { accountName = "charlie"
              , loginCount = 2
              , isActive = False
              }

      accountName (activateAccount account)
        `shouldBe` "charlie"

    it "ログイン回数を変更しない" $ do
      let account =
            Account
              { accountName = "dave"
              , loginCount = 25
              , isActive = False
              }

      loginCount (activateAccount account)
        `shouldBe` 25

  describe "activateRegisteredAccount" $ do
    it "Right内のアカウントを有効化する" $ do
      let account =
            Account
              { accountName = "alice"
              , loginCount = 0
              , isActive = False
              }

          expected =
            Right
              Account
                { accountName = "alice"
                , loginCount = 0
                , isActive = True
                }

      activateRegisteredAccount (Right account)
        `shouldBe` expected

    it "Right内の既に有効なアカウントを変更しない" $ do
      let account =
            Account
              { accountName = "bob"
              , loginCount = 7
              , isActive = True
              }

      activateRegisteredAccount (Right account)
        `shouldBe` Right account

    it "Leftの名前エラーをそのまま返す" $ do
      activateRegisteredAccount
        (Left EmptyAccountName)
        `shouldBe` Left EmptyAccountName

    it "Leftのログイン回数エラーをそのまま返す" $ do
      activateRegisteredAccount
        (Left (NegativeLoginCount (-3)))
        `shouldBe` Left (NegativeLoginCount (-3))

    it "検証成功後のアカウントを有効化できる" $ do
      let account =
            Account
              { accountName = "eve"
              , loginCount = 1
              , isActive = False
              }

          expected =
            Right
              Account
                { accountName = "eve"
                , loginCount = 1
                , isActive = True
                }

      activateRegisteredAccount
        (validateAccount account)
        `shouldBe` expected

    it "検証失敗後のエラーを維持する" $ do
      let account =
            Account
              { accountName = ""
              , loginCount = 1
              , isActive = False
              }

      activateRegisteredAccount
        (validateAccount account)
        `shouldBe` Left EmptyAccountName
