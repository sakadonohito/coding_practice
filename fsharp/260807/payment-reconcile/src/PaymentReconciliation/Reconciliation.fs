module PaymentReconciliationService

type Invoice =
    { InvoiceId: string
      CustomerName: string
      Amount: int }

type Payment =
    { PaymentId: string
      InvoiceId: string
      Amount: int }

type RejectionReason = | UnknownInvoice

type AppliedPayment =
    { PaymentId: string
      InvoiceId: string
      AppliedAmount: int
      ExcessAmount: int
      RemainingBalance: int }

type PaymentDecision =
    | Applied of AppliedPayment
    | Rejected of paymentId: string * invoiceId: string * reason: RejectionReason

type InvoiceStatus =
    | Unpaid
    | PartiallyPaid of paidAmount: int
    | Paid

type InvoiceBalance =
    { InvoiceId: string
      OriginalAmount: int
      RemainingAmount: int
      Status: InvoiceStatus }

type ReconciliationReport =
    { Decisions: PaymentDecision list
      InvoiceBalances: InvoiceBalance list
      TotalPaymentAmount: int
      TotalAppliedAmount: int
      TotalExcessAmount: int
      RejectedPaymentAmount: int }

type ReconciliationError =
    | BlankInvoiceId of index: int
    | BlankCustomerName of invoiceId: string
    | InvalidInvoiceAmount of invoiceId: string * value: int
    | DuplicateInvoiceId of invoiceId: string
    | BlankPaymentId of index: int
    | BlankPaymentInvoiceId of paymentId: string
    | InvalidPaymentAmount of paymentId: string * value: int
    | DuplicatePaymentId of paymentId: string

let private validateInvoices (invoices: Invoice list) : Result<unit, ReconciliationError> =
    let duplicateIds =
        invoices
        |> List.countBy (fun s -> s.InvoiceId)
        |> List.filter (fun (id, count) -> count > 1)
        |> List.map fst
        |> Set.ofList

    let firstError =
        invoices
        |> List.indexed
        |> List.tryPick (fun (idx, invoice) ->
            if System.String.IsNullOrWhiteSpace invoice.InvoiceId then
                Some(ReconciliationError.BlankInvoiceId idx)
            elif System.String.IsNullOrWhiteSpace invoice.CustomerName then
                Some(ReconciliationError.BlankCustomerName invoice.InvoiceId)
            elif invoice.Amount < 1 then
                Some(ReconciliationError.InvalidInvoiceAmount(invoice.InvoiceId, invoice.Amount))
            elif Set.contains invoice.InvoiceId duplicateIds then
                Some(ReconciliationError.DuplicateInvoiceId(invoice.InvoiceId))
            else
                None)

    match firstError with
    | Some err -> Error err
    | None -> Ok()


let private validatePayments (payments: Payment list) : Result<unit, ReconciliationError> =
    let duplicateIds =
        payments
        |> List.countBy (fun s -> s.PaymentId)
        |> List.filter (fun (id, count) -> count > 1)
        |> List.map fst
        |> Set.ofList

    let check =
        payments
        |> List.indexed
        |> List.tryPick (fun (idx, payment) ->
            if System.String.IsNullOrWhiteSpace payment.PaymentId then
                Some(ReconciliationError.BlankPaymentId idx)
            elif System.String.IsNullOrWhiteSpace payment.InvoiceId then
                Some(ReconciliationError.BlankPaymentInvoiceId payment.PaymentId)
            elif payment.Amount < 1 then
                Some(ReconciliationError.InvalidPaymentAmount(payment.PaymentId, payment.Amount))
            elif Set.contains payment.PaymentId duplicateIds then
                Some(ReconciliationError.DuplicatePaymentId payment.PaymentId)
            else
                None)

    match check with
    | Some err -> Error err
    | None -> Ok()


type private FoldState =
    { Balances: Map<string, int>
      DecisionsReversed: PaymentDecision list
      TotalPaymentAmount: int
      TotalAppliedAmount: int
      TotalExcessAmount: int
      RejectedPaymentAmount: int }

let private applyPayment (state: FoldState) (payment: Payment) : FoldState =
    match Map.tryFind payment.InvoiceId state.Balances with
    | None ->
        let decision = Rejected(payment.PaymentId, payment.InvoiceId, UnknownInvoice)

        { state with
            DecisionsReversed = decision :: state.DecisionsReversed
            TotalPaymentAmount = state.TotalPaymentAmount + payment.Amount
            RejectedPaymentAmount = state.RejectedPaymentAmount + payment.Amount }
    | Some currentBalance ->
        let appliedAmount = min payment.Amount currentBalance
        let excessAmount = payment.Amount - appliedAmount
        let remainingBalance = currentBalance - appliedAmount
        let newBalances = Map.add payment.InvoiceId remainingBalance state.Balances

        let applied =
            { PaymentId = payment.PaymentId
              InvoiceId = payment.InvoiceId
              AppliedAmount = appliedAmount
              ExcessAmount = excessAmount
              RemainingBalance = remainingBalance }

        let decision = Applied applied

        { state with
            Balances = newBalances
            DecisionsReversed = decision :: state.DecisionsReversed
            TotalPaymentAmount = state.TotalPaymentAmount + payment.Amount
            TotalAppliedAmount = state.TotalAppliedAmount + appliedAmount
            TotalExcessAmount = state.TotalExcessAmount + excessAmount }

let private createInvoiceBalance (balances: Map<string, int>) (invoice: Invoice) : InvoiceBalance =
    let remaining = Map.find invoice.InvoiceId balances

    let status =
        if remaining = invoice.Amount then Unpaid
        elif remaining = 0 then Paid
        else PartiallyPaid(invoice.Amount - remaining)

    { InvoiceId = invoice.InvoiceId
      OriginalAmount = invoice.Amount
      RemainingAmount = remaining
      Status = status }

let reconcilePayments
    (invoices: Invoice list)
    (payments: Payment list)
    : Result<ReconciliationReport, ReconciliationError> =

    match validateInvoices invoices with
    | Error err -> Error err
    | Ok() ->
        match validatePayments payments with
        | Error err -> Error err
        | Ok() ->
            let initialBalances =
                invoices
                |> List.map (fun invoice -> invoice.InvoiceId, invoice.Amount)
                |> Map.ofList

            let initialState =
                { Balances = initialBalances
                  DecisionsReversed = []
                  TotalPaymentAmount = 0
                  TotalAppliedAmount = 0
                  TotalExcessAmount = 0
                  RejectedPaymentAmount = 0 }

            let finalState = payments |> List.fold applyPayment initialState

            let invoiceBalances =
                invoices |> List.map (createInvoiceBalance finalState.Balances)

            Ok
                { Decisions = finalState.DecisionsReversed |> List.rev
                  InvoiceBalances = invoiceBalances
                  TotalPaymentAmount = finalState.TotalPaymentAmount
                  TotalAppliedAmount = finalState.TotalAppliedAmount
                  TotalExcessAmount = finalState.TotalExcessAmount
                  RejectedPaymentAmount = finalState.RejectedPaymentAmount }
