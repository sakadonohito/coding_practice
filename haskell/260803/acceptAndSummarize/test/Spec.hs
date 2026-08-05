module Main (main) where

import Lib
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "acceptReservation" $ do
    it "通常の予約リクエストを受付済み予約へ変換する" $ do
      let request =
            ReservationRequest
              { customerName = "Alice",
                partySize = 4
              }

      case acceptReservation request of
        Left err ->
          expectationFailure ("予期しないエラー: " ++ show err)
        Right accepted ->
          reservationSummary accepted
            `shouldBe` "Alice: 4名"

    it "下限の1人を受け付ける" $ do
      acceptAndSummarize
        ( ReservationRequest
            { customerName = "Bob",
              partySize = 1
            }
        )
        `shouldBe` Right "Bob: 1名"

    it "上限の8人を受け付ける" $ do
      acceptAndSummarize
        ( ReservationRequest
            { customerName = "Carol",
              partySize = 8
            }
        )
        `shouldBe` Right "Carol: 8名"

    it "空の顧客名をエラーにする" $ do
      acceptReservation
        ( ReservationRequest
            { customerName = "",
              partySize = 4
            }
        )
        `shouldBe` Left CustomerNameMustNotBeEmpty

    it "人数0をエラーにする" $ do
      acceptReservation
        ( ReservationRequest
            { customerName = "Dave",
              partySize = 0
            }
        )
        `shouldBe` Left (PartySizeMustBePositive 0)

    it "負の人数をエラーにする" $ do
      acceptReservation
        ( ReservationRequest
            { customerName = "Eve",
              partySize = -1
            }
        )
        `shouldBe` Left (PartySizeMustBePositive (-1))

    it "上限を1人超える予約を入力人数と上限付きのエラーにする" $ do
      acceptReservation
        ( ReservationRequest
            { customerName = "Frank",
              partySize = 9
            }
        )
        `shouldBe` Left
          PartySizeExceedsLimit
            { requestedPartySize = 9,
              maximumPartySize = 8
            }

    it "名前と人数が両方不正なら名前のエラーを先に返す" $ do
      acceptReservation
        ( ReservationRequest
            { customerName = "",
              partySize = 0
            }
        )
        `shouldBe` Left CustomerNameMustNotBeEmpty

    it "空白だけの名前は今回の仕様ではそのまま受け付ける" $ do
      acceptAndSummarize
        ( ReservationRequest
            { customerName = " ",
              partySize = 2
            }
        )
        `shouldBe` Right " : 2名"

  describe "acceptAndSummarize" $ do
    it "受付成功後に表示文を返す" $ do
      acceptAndSummarize
        ( ReservationRequest
            { customerName = "Grace",
              partySize = 3
            }
        )
        `shouldBe` Right "Grace: 3名"

    it "受付失敗時は表示文を作らず同じエラーを返す" $ do
      acceptAndSummarize
        ( ReservationRequest
            { customerName = "Heidi",
              partySize = 10
            }
        )
        `shouldBe` Left
          PartySizeExceedsLimit
            { requestedPartySize = 10,
              maximumPartySize = 8
            }
