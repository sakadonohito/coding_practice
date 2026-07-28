module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "validateAccountName" $ do
    it "3文字以上の名前をRightで返す" $ do
      validateAccountName "alice"
        `shouldBe` Right (ValidAccountName "alice")

    it "ちょうど3文字の名前を有効とする" $ do
      validateAccountName "bob"
        `shouldBe` Right (ValidAccountName "bob")

    it "空文字をEmptyAccountNameにする" $ do
      validateAccountName ""
        `shouldBe` Left EmptyAccountName

    it "1文字の名前を実際の長さを含むエラーにする" $ do
      validateAccountName "a"
        `shouldBe` Left (AccountNameTooShort 1)

    it "2文字の名前を実際の長さを含むエラーにする" $ do
      validateAccountName "ab"
        `shouldBe` Left (AccountNameTooShort 2)

    it "空白だけでも3文字あれば長さの条件上は有効とする" $ do
      validateAccountName "   "
        `shouldBe` Right (ValidAccountName "   ")

  describe "createAccount" $ do
    it "未使用の名前から無効状態のアカウントを作成する" $ do
      let existingNames =
            [ "alice",
              "bob"
            ]

          expected =
            Right
              Account
                { accountName = "charlie",
                  isActive = False
                }

      createAccount existingNames (ValidAccountName "charlie")
        `shouldBe` expected

    it "既に存在する名前を重複エラーにする" $ do
      let existingNames =
            [ "alice",
              "bob"
            ]

      createAccount existingNames (ValidAccountName "alice")
        `shouldBe` Left (AccountNameAlreadyExists "alice")

    it "既存一覧が空ならアカウントを作成する" $ do
      let expected =
            Right
              Account
                { accountName = "alice",
                  isActive = False
                }

      createAccount [] (ValidAccountName "alice")
        `shouldBe` expected

    it "大文字と小文字が異なる名前は重複としない" $ do
      let existingNames =
            ["alice"]

          expected =
            Right
              Account
                { accountName = "Alice",
                  isActive = False
                }

      createAccount existingNames (ValidAccountName "Alice")
        `shouldBe` expected

    it "重複エラーには入力された名前を保持する" $ do
      createAccount ["taken-name"] (ValidAccountName "taken-name")
        `shouldBe` Left
          (AccountNameAlreadyExists "taken-name")

  describe "registerAccount" $ do
    it "有効かつ未使用の名前からアカウントを登録する" $ do
      let existingNames =
            [ "alice",
              "bob"
            ]

          expected =
            Right
              Account
                { accountName = "charlie",
                  isActive = False
                }

      registerAccount existingNames "charlie"
        `shouldBe` expected

    it "空の名前では形式検証エラーを返す" $ do
      registerAccount ["alice"] ""
        `shouldBe` Left EmptyAccountName

    it "短すぎる名前では形式検証エラーを返す" $ do
      registerAccount ["alice"] "ab"
        `shouldBe` Left (AccountNameTooShort 2)

    it "有効だが既に存在する名前では重複エラーを返す" $ do
      registerAccount ["alice", "bob"] "alice"
        `shouldBe` Left (AccountNameAlreadyExists "alice")

    it "形式検証に失敗した場合は重複確認へ進まない" $ do
      registerAccount [""] ""
        `shouldBe` Left EmptyAccountName

    it "境界値の3文字かつ未使用の名前を登録する" $ do
      let expected =
            Right
              Account
                { accountName = "eve",
                  isActive = False
                }

      registerAccount ["alice", "bob"] "eve"
        `shouldBe` expected

    it "既存一覧が空なら有効な名前を登録する" $ do
      let expected =
            Right
              Account
                { accountName = "alice",
                  isActive = False
                }

      registerAccount [] "alice"
        `shouldBe` expected
