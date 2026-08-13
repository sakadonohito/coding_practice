open PaymentReconciliationService

let invoices =
    [ { InvoiceId = "INV-001"
        CustomerName = "株式会社サンプル"
        Amount = 10_000 }
      { InvoiceId = "INV-002"
        CustomerName = "合同会社テスト"
        Amount = 5_000 } ]

let payments =
    [ { PaymentId = "PAY-001"
        InvoiceId = "INV-001"
        Amount = 4_000 }
      { PaymentId = "PAY-002"
        InvoiceId = "INV-001"
        Amount = 7_000 }
      { PaymentId = "PAY-003"
        InvoiceId = "INV-999"
        Amount = 1_000 }
      { PaymentId = "PAY-004"
        InvoiceId = "INV-002"
        Amount = 5_000 } ]

match reconcilePayments invoices payments with
| Ok report ->
    printfn "%A" report
| Error error ->
    eprintfn "入力エラー: %A" error
