module BookingAppTests

open Expecto
open BookingAppService

let existingReservations =
    [ { Title = "朝会"
        StartHour = 9
        EndHour = 10 }
      { Title = "企画会議"
        StartHour = 13
        EndHour = 15 } ]

[<Tests>]
let tests =
    testList
        "createReservation"
        [

          testCase "空白を除去したタイトルで予約を作成できる"
          <| fun _ ->
              // 営業時間を9時から18時にしてください。
              // 既存予約一覧を渡してください。
              // タイトルに" 定例会議 "を渡してください。
              // 開始時刻10、終了時刻11を渡してください。
              // 結果が次になることを確認してください。
              //
              // Ok {
              //     Title = "定例会議"
              //     StartHour = 10
              //     EndHour = 11
              // }
              let actual = createReservation 9 18 existingReservations " 定例会議 " 10 11

              let expected =
                  Ok
                      { Title = "定例会議"
                        StartHour = 10
                        EndHour = 11 }

              Expect.equal actual expected "定例会議：10~11時が追加されること"

          testCase "タイトルが空白だけならEmptyTitleを返す"
          <| fun _ ->
              // タイトルに空白だけの文字列を渡してください。
              let actual = createReservation 9 18 existingReservations "  " 10 11
              // 結果がError EmptyTitleになることを確認してください。
              let expected = Error EmptyTitle
              Expect.equal actual expected "EmptyTitle エラーが返ること"

          testCase "開始時刻と終了時刻が同じならInvalidTimeRangeを返す"
          <| fun _ ->
              // 開始時刻と終了時刻の両方に10を渡してください。
              let actual = createReservation 9 18 existingReservations " 定例会議 " 10 10
              // 結果がError InvalidTimeRangeになることを確認してください。
              let expected = Error InvalidTimeRange
              Expect.equal actual expected "InvalidTimeRange エラーが返ること"

          testCase "開始時刻が終了時刻より後ならInvalidTimeRangeを返す"
          <| fun _ ->
              // 開始時刻12、終了時刻11を渡してください。
              let actual = createReservation 9 18 existingReservations " 定例会議 " 12 11
              // 結果がError InvalidTimeRangeになることを確認してください。
              let expected = Error InvalidTimeRange
              Expect.equal actual expected "InvalidTimeRange エラーが返ること"

          testCase "営業時間より前ならOutsideBusinessHoursを返す"
          <| fun _ ->
              // 営業時間を9時から18時にしてください。
              // 開始時刻8、終了時刻10を渡してください。
              let actual = createReservation 9 18 existingReservations " 定例会議 " 8 10
              // 結果がError OutsideBusinessHoursになることを確認してください。
              let expected = Error OutsideBusinessHours
              Expect.equal actual expected "OutsideBusinessHours エラーが返ること"

          testCase "営業時間より後ならOutsideBusinessHoursを返す"
          <| fun _ ->
              // 営業時間を9時から18時にしてください。
              // 開始時刻17、終了時刻19を渡してください。
              let actual = createReservation 9 18 existingReservations " 定例会議 " 17 19
              // 結果がError OutsideBusinessHoursになることを確認してください。
              let expected = Error OutsideBusinessHours
              Expect.equal actual expected "OutsideBusinessHours エラーが返ること"

          testCase "既存予約と重複したら予約タイトルを含むエラーを返す"
          <| fun _ ->
              // 既存の企画会議は13時から15時です。
              // 新しい予約として14時から16時を渡してください。
              let actual = createReservation 9 18 existingReservations " 定例会議 " 14 16
              // 結果が次になることを確認してください。
              //
              // Error (
              //     OverlappingReservation "企画会議"
              // )
              let expected = Error(OverlappingReservation "企画会議")
              Expect.equal actual expected "OverlappingReservation 企画会議 というエラーが返ること"

          testCase "既存予約の終了時刻から始まる予約は作成できる"
          <| fun _ ->
              // 朝会は9時から10時です。
              // 新しい予約として10時から11時を渡してください。
              let actual = createReservation 9 18 existingReservations "定例会議" 10 11
              // 重複エラーにならず、Okになることを確認してください。
              let expected =
                  Ok
                      { Title = "定例会議"
                        StartHour = 10
                        EndHour = 11 }

              Expect.equal actual expected "定例会議：10~11時が追加されること"
          // 最初のテストと内容が実質同じ

          testCase "既存予約の開始時刻に終了する予約は作成できる"
          <| fun _ ->
              // 企画会議は13時から15時です。
              // 新しい予約として12時から13時を渡してください。
              let actual = createReservation 9 18 existingReservations "新しい予約" 12 13
              // 重複エラーにならず、Okになることを確認してください。
              let expected =
                  Ok
                      { Title = "新しい予約"
                        StartHour = 12
                        EndHour = 13 }

              Expect.equal actual expected "新しい予約：12~13時が追加されること" ]
