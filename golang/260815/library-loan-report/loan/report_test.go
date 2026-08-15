package loan_test

import (
	"errors"
	"reflect"
	"testing"

	"example.com/library-loan-report/loan"
)

func validLoan() loan.Loan {
	return loan.Loan{
		ID:         "LOAN-001",
		Title:      "Go入門",
		BorrowedOn: "2026-08-01",
		DueOn:      "2026-08-10",
		ReturnedOn: "",
	}
}

func TestBuildReportReturnedOnTime(t *testing.T) {
	l := validLoan()
	l.ReturnedOn = "2026-08-10"

	report, err := loan.BuildReport([]loan.Loan{l}, "2026-08-15")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if len(report.Decisions) != 1 {
		t.Fatalf("expected 1 decision, got %d", len(report.Decisions))
	}

	d := report.Decisions[0]
	if d.State != loan.LoanStateReturned {
		t.Errorf("expected state %s, got %s", loan.LoanStateReturned, d.State)
	}
	if d.OverdueDays != 0 {
		t.Errorf("expected 0 overdue days, got %d", d.OverdueDays)
	}
	if d.LateFee != 0 {
		t.Errorf("expected 0 late fee, got %d", d.LateFee)
	}
}

func TestBuildReportDueTodayIsActive(t *testing.T) {
	l := validLoan()
	l.DueOn = "2026-08-15"
	report, err := loan.BuildReport([]loan.Loan{l}, "2026-08-15")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if len(report.Decisions) != 1 {
		t.Fatalf("expected 1 decision, got %d", len(report.Decisions))
	}

	d := report.Decisions[0]
	if d.State != loan.LoanStateActive {
		t.Errorf("expected state %s, got %s", loan.LoanStateActive, d.State)
	}
	if report.ActiveCount != 1 {
		t.Errorf("expected 1 ActiveCount, got %d", report.ActiveCount)
	}
	if report.OverdueCount != 0 {
		t.Errorf("expected 0 OverdueCount, got %d", report.OverdueCount)
	}
}

func TestBuildReportCalculatesLateFee(t *testing.T) {
	tests := []struct {
		name            string
		loan            loan.Loan
		asOf            string
		wantState       loan.LoanState
		wantOverdueDays int
		wantLateFee     int
	}{
		{
			name: "未返却で2日延滞",
			loan: loan.Loan{
				ID:         "LOAN-001",
				Title:      "Go入門",
				BorrowedOn: "2026-08-01",
				DueOn:      "2026-08-10",
			},
			asOf:            "2026-08-12",
			wantState:       loan.LoanStateOverdue,
			wantOverdueDays: 2,
			wantLateFee:     200,
		},
		{
			name: "3日遅れて返却",
			loan: loan.Loan{
				ID:         "LOAN-001",
				Title:      "Go入門",
				BorrowedOn: "2026-07-20",
				DueOn:      "2026-08-01",
				ReturnedOn: "2026-08-04",
			},
			asOf:            "2026-08-15",
			wantState:       loan.LoanStateReturned,
			wantOverdueDays: 3,
			wantLateFee:     300,
		},
		{
			name: "長期延滞は2000円で上限",
			loan: loan.Loan{
				ID:         "LOAN-001",
				Title:      "Go入門",
				BorrowedOn: "2026-06-20",
				DueOn:      "2026-07-01",
			},
			asOf:            "2026-08-15",
			wantState:       loan.LoanStateOverdue,
			wantOverdueDays: 45,
			wantLateFee:     2000,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := loan.BuildReport([]loan.Loan{tt.loan}, tt.asOf)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			d := got.Decisions[0]
			if d.State != tt.wantState {
				t.Errorf("expected state %s, got %s", tt.wantState, d.State)
			}
			if d.OverdueDays != tt.wantOverdueDays {
				t.Errorf("expected %d overdue days, got %d", tt.wantOverdueDays, d.OverdueDays)
			}
			if d.LateFee != tt.wantLateFee {
				t.Errorf("expected %d late fee, got %d", tt.wantLateFee, d.LateFee)
			}
		})
	}
}

func TestBuildReportAggregatesInInputOrder(t *testing.T) {
	loans := []loan.Loan{
		{
			ID:         "LOAN-001",
			Title:      "貸出中の本",
			BorrowedOn: "2026-08-01",
			DueOn:      "2026-08-20",
		},
		{
			ID:         "LOAN-002",
			Title:      "延滞中の本",
			BorrowedOn: "2026-08-01",
			DueOn:      "2026-08-10",
		},
		{
			ID:         "LOAN-003",
			Title:      "遅れて返した本",
			BorrowedOn: "2026-07-20",
			DueOn:      "2026-08-05",
			ReturnedOn: "2026-08-08",
		},
	}

	report, err := loan.BuildReport(loans, "2026-08-15")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if len(report.Decisions) != 3 {
		t.Fatalf("expected 3 decision, got %d", len(report.Decisions))
	}

	expectedIDs := []string{"LOAN-001", "LOAN-002", "LOAN-003"}
	for i, wantID := range expectedIDs {
		if report.Decisions[i].LoanID != wantID {
			t.Errorf("decisions[%d].LoanID: expected %s, got %s", i, wantID, report.Decisions[i].LoanID)
		}
	}

	if report.ActiveCount != 1 {
		t.Errorf("expected 1 ActiveCount, got %d", report.ActiveCount)
	}
	if report.OverdueCount != 1 {
		t.Errorf("expected 1 OverdueCount, got %d", report.OverdueCount)
	}
	if report.ReturnedCount != 1 {
		t.Errorf("expected 1 ReturnedCount, got %d", report.ReturnedCount)
	}
	if report.TotalLateFees != 800 {
		t.Errorf("expected 800 TotalLateFee, got %d", report.TotalLateFees)
	}
}

func TestBuildReportEmptyLoans(t *testing.T) {
	report, err := loan.BuildReport([]loan.Loan{}, "2026-08-15")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if report.Decisions == nil {
		t.Fatalf("expected not nil Decisions: %v", report.Decisions)
	}
	if len(report.Decisions) != 0 {
		t.Fatalf("expected 0 Decisions length: %v", len(report.Decisions))
	}
	if report.ActiveCount != 0 {
		t.Errorf("expected 0 ActiveCount, got %d", report.ActiveCount)
	}
	if report.OverdueCount != 0 {
		t.Errorf("expected 0 OverdueCount, got %d", report.OverdueCount)
	}
	if report.ReturnedCount != 0 {
		t.Errorf("expected 0 ReturnedCount, got %d", report.ReturnedCount)
	}
	if report.TotalLateFees != 0 {
		t.Errorf("expected 0 TotalLateFee, got %d", report.TotalLateFees)
	}
}

func TestBuildReportRejectsInvalidInput(t *testing.T) {
	base := validLoan()

	tests := []struct {
		name       string
		loans      []loan.Loan
		asOf       string
		wantLoanID string
		wantField  string
		wantValue  string
		wantReason string
	}{
		{
			name:       "基準日が不正",
			loans:      []loan.Loan{base},
			asOf:       "2026-02-30",
			wantField:  "as_of",
			wantValue:  "2026-02-30",
			wantReason: loan.ReasonInvalidDate,
		},
		{
			name: "IDが空白",
			loans: []loan.Loan{
				{
					ID:         "   ",
					Title:      base.Title,
					BorrowedOn: base.BorrowedOn,
					DueOn:      base.DueOn,
				},
			},
			asOf:       "2026-08-15",
			wantLoanID: "   ",
			wantField:  "id",
			wantValue:  "   ",
			wantReason: loan.ReasonRequired,
		},
		{
			name:       "書名が空白",
			loans:      []loan.Loan{{ID: base.ID, Title: "   ", BorrowedOn: base.BorrowedOn, DueOn: base.DueOn}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "title",
			wantValue:  "   ",
			wantReason: loan.ReasonRequired,
		},
		{
			name:       "貸出日が不正",
			loans:      []loan.Loan{{ID: base.ID, Title: base.Title, BorrowedOn: "invalid", DueOn: base.DueOn}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "borrowed_on",
			wantValue:  "invalid",
			wantReason: loan.ReasonInvalidDate,
		},
		{
			name:       "期限の日付が不正",
			loans:      []loan.Loan{{ID: base.ID, Title: base.Title, BorrowedOn: base.BorrowedOn, DueOn: "2026-02-30"}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "due_on",
			wantValue:  "2026-02-30",
			wantReason: loan.ReasonInvalidDate,
		},
		{
			name:       "期限が貸出日より前",
			loans:      []loan.Loan{{ID: base.ID, Title: base.Title, BorrowedOn: "2026-08-10", DueOn: "2026-08-09"}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "due_on",
			wantValue:  "2026-08-09",
			wantReason: loan.ReasonBeforeBorrowed,
		},
		{
			name:       "返却日が不正",
			loans:      []loan.Loan{{ID: base.ID, Title: base.Title, BorrowedOn: base.BorrowedOn, DueOn: base.DueOn, ReturnedOn: "invalid"}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "returned_on",
			wantValue:  "invalid",
			wantReason: loan.ReasonInvalidDate,
		},
		{
			name:       "返却日が貸出日より前",
			loans:      []loan.Loan{{ID: base.ID, Title: base.Title, BorrowedOn: "2026-08-05", DueOn: "2026-08-10", ReturnedOn: "2026-08-04"}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "returned_on",
			wantValue:  "2026-08-04",
			wantReason: loan.ReasonBeforeBorrowed,
		},
		{
			name:       "返却日が基準日より後",
			loans:      []loan.Loan{{ID: base.ID, Title: base.Title, BorrowedOn: base.BorrowedOn, DueOn: base.DueOn, ReturnedOn: "2026-08-16"}},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "returned_on",
			wantValue:  "2026-08-16",
			wantReason: loan.ReasonAfterAsOf,
		},
		{
			name:       "IDが重複",
			loans:      []loan.Loan{base, base},
			asOf:       "2026-08-15",
			wantLoanID: base.ID,
			wantField:  "id",
			wantValue:  base.ID,
			wantReason: loan.ReasonDuplicateLoanID,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := loan.BuildReport(tt.loans, tt.asOf)
			if err == nil {
				t.Fatalf("expected error, got nil")
			}

			var validationErr *loan.ValidationError
			if !errors.As(err, &validationErr) {
				t.Fatalf("error type = %T, want *loan.ValidationError", err)
			}

			if validationErr.LoanID != tt.wantLoanID {
				t.Errorf("LoanID: expected %q, got %q", tt.wantLoanID, validationErr.LoanID)
			}
			if validationErr.Field != tt.wantField {
				t.Errorf("Field: expected %q, got %q", tt.wantField, validationErr.Field)
			}
			if validationErr.Value != tt.wantValue {
				t.Errorf("Value: expected %q, got %q", tt.wantValue, validationErr.Value)
			}
			if validationErr.Reason != tt.wantReason {
				t.Errorf("Reason: expected %q, got %q", tt.wantReason, validationErr.Reason)
			}
		})
	}
}

// TODOを実装するとreflectとerrorsを使用します。
// 実装途中で未使用importのコンパイルエラーになる場合は、
// 対応するテストを書くまで一時的にimportから外して構いません。
var (
	_ = errors.As
	_ = reflect.DeepEqual
)
