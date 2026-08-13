module PaymentReconciliationTests

open Expecto
open PaymentReconciliationService

let invoice invoiceId amount =
    { InvoiceId = invoiceId
      CustomerName = "テスト顧客"
      Amount = amount }

let payment paymentId invoiceId amount =
    { PaymentId = paymentId
      InvoiceId = invoiceId
      Amount = amount }

[<Tests>]
let tests =
    testList
        "reconcilePayments"
        [ testCase "部分入金の後に完済できる"
          <| fun _ ->
              let invs = [ invoice "INV-001" 10_000 ]
              let pmts = [ payment "PAY-001" "INV-001" 4_000; payment "PAY-002" "INV-001" 6_000 ]

              match reconcilePayments invs pmts with
              | Ok report ->
                  Expect.equal report.TotalAppliedAmount 10_000 "適用合計額は 10,000円"

                  let invBalance = report.InvoiceBalances.[0]
                  Expect.equal invBalance.Status Paid "最終ステータスは Paid"

              | Error err -> failtest $"Ok を期待したが Error になった： %A{err}"

          testCase "過入金は残高まで適用して超過額を返す"
          <| fun _ ->
              let invs = [ invoice "INV-001" 3_000 ]
              let pmts = [ payment "PAY-001" "INV-001" 5_000 ]

              match reconcilePayments invs pmts with
              | Ok report ->
                  Expect.equal report.TotalExcessAmount 2_000 "最終返金額は2,000円"
                  match report.Decisions.[0] with
                  | Applied p ->
                      Expect.equal p.AppliedAmount 3_000 "適用金額は3,000円"
                      Expect.equal p.ExcessAmount 2_000 "超過金額は2,000円"
                      Expect.equal p.RemainingBalance 0 "未収は0円"
                  | Rejected _ ->
                      failtest "Applied を期待しましたが Rejected になりました"
              | Error err ->
                  failtest $"Error になりました: %A{err}"

          testCase "不明な請求書への入金を拒否して処理を続ける"
          <| fun _ ->
              let invs = [ invoice "INV-001" 5_000 ]
              let pmts = [ payment "PAY-001" "INV-999" 1_000;
                           payment "PAY-002" "INV-001" 5_000 ]

              match reconcilePayments invs pmts with
              | Ok report ->
                  Expect.equal report.Decisions.Length 2 "2件"
                  Expect.equal report.RejectedPaymentAmount 1_000 "不明な請求書への入金1,000円"
                  Expect.equal report.InvoiceBalances.[0]
                               { InvoiceId = "INV-001"
                                 OriginalAmount = 5_000
                                 RemainingAmount = 0
                                 Status = Paid }
                               "未収なしの正常入金データ"

                  match report.Decisions.[0] with
                  | Rejected (p, i, reason) ->
                      Expect.equal p "PAY-001" "謎の入金データ"
                      Expect.equal i "INV-999" "不明な請求IDデータ"
                      Expect.equal reason UnknownInvoice "Reject: Unknown Invoice"
                  | Applied p ->
                      failtest "Rejected を期待しましたが Applied になりました"

              | Error err ->
                  failtest $"Error になりました: %A{err}"

          testCase "入金がなければ全請求書が未払い"
          <| fun _ ->
              let invs = [ invoice "INV-001" 5_000; invoice "INV-002" 3_000 ]
              let pmts = []

              match reconcilePayments invs pmts with
              | Ok report ->
                  Expect.equal report.Decisions [] "Decisions は空リスト"
                  Expect.equal report.TotalPaymentAmount 0 "TotalPaymentAmount は 0"
                  Expect.equal report.TotalAppliedAmount 0 "TotalAppliedAmount は 0"
                  Expect.equal report.TotalExcessAmount 0 "TotalExcessAmount は 0"
                  Expect.equal report.RejectedPaymentAmount 0 "RejectedPaymentAmount は 0"

                  Expect.equal report.InvoiceBalances.[0].InvoiceId "INV-001" "1件目のID順"
                  Expect.equal report.InvoiceBalances.[0].Status Unpaid "1件目のStatusはUnpaid"
                  Expect.equal report.InvoiceBalances.[1].InvoiceId "INV-002" "2件目のID順"
                  Expect.equal report.InvoiceBalances.[1].Status Unpaid "2件目のStatusはUnpaid"

                  let expected = invs |> List.map (fun i -> i.InvoiceId)
                  let actual = report.InvoiceBalances |> List.map (fun b -> b.InvoiceId)
                  Expect.equal actual expected "元の請求書順が維持されていること"

              | Error err ->
                  failtest $"Error になりました: %A{err}"

          testCase "重複したPaymentIdを入力エラーにする"
          <| fun _ ->
              let invs = [ invoice "INV-001" 3_000; invoice "INV-002" 3_000 ]
              let pmts = [ payment "PAY-001" "INV-001" 3_000;
                           payment "PAY-001" "INV-002" 3_000 ]

              let actual = reconcilePayments invs pmts
              let expected = Error (DuplicatePaymentId "PAY-001")

              Expect.equal actual expected "重複したPaymentIdがエラーになること"

          testCase "不正な金額を表形式で検証する"
          <| fun _ ->
              let cases =
                  [ ("請求額0",
                     (fun () -> reconcilePayments [ invoice "INV-001" 0 ] []),
                     Error (InvalidInvoiceAmount ("INV-001", 0)))
                    ("請求額-1",
                     (fun () -> reconcilePayments [ invoice "INV-001" -1 ] []),
                     Error (InvalidInvoiceAmount ("INV-001", -1)))
                    ("入金額0",
                     (fun () -> reconcilePayments [ invoice "INV-001" 5_000 ] [ payment "PAY-001" "INV-001" 0 ]),
                     Error (InvalidPaymentAmount ("PAY-001", 0)))
                    ("入金額-1",
                     (fun () -> reconcilePayments [ invoice "INV-001" 5_000 ] [ payment "PAY-001" "INV-001" -1 ]),
                     Error (InvalidPaymentAmount ("PAY-001", -1))) ]

              cases
              |> List.iter (fun (name, run, expected) ->
                  let actual = run ()
                  Expect.equal actual expected name)
        ]
