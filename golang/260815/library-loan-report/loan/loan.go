// Package loan provides library loan status and late-fee reporting.
package loan

import "fmt"

const DateLayout = "2006-01-02"

const (
	ReasonRequired        = "must not be blank"
	ReasonInvalidDate     = "must be a valid date in YYYY-MM-DD format"
	ReasonBeforeBorrowed  = "must not be before borrowed_on"
	ReasonAfterAsOf       = "must not be after as_of"
	ReasonDuplicateLoanID = "must not be duplicated"
)

type LoanState string

const (
	LoanStateActive   LoanState = "active"
	LoanStateReturned LoanState = "returned"
	LoanStateOverdue  LoanState = "overdue"
)

type Loan struct {
	ID         string
	Title      string
	BorrowedOn string
	DueOn      string
	ReturnedOn string
}

type LoanDecision struct {
	LoanID      string
	Title       string
	State       LoanState
	OverdueDays int
	LateFee     int
}

type Report struct {
	Decisions     []LoanDecision
	ActiveCount   int
	ReturnedCount int
	OverdueCount  int
	TotalLateFees int
}

type ValidationError struct {
	LoanID string
	Field  string
	Value  string
	Reason string
}

func (e *ValidationError) Error() string {
	if e.LoanID == "" {
		return fmt.Sprintf(
			"invalid %s %q: %s",
			e.Field,
			e.Value,
			e.Reason,
		)
	}

	return fmt.Sprintf(
		"invalid loan %q field %s %q: %s",
		e.LoanID,
		e.Field,
		e.Value,
		e.Reason,
	)
}
