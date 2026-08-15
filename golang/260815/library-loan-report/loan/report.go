package loan

import (
	"strings"
	"time"
)

const (
	lateFeePerDay  = 100
	maximumLateFee = 2000
)

func parseDate(
	value string,
	field string,
	loanID string,
) (time.Time, error) {
	isValidDate, err := time.Parse(DateLayout, value)
	if err != nil {
		return time.Time{}, &ValidationError{
			LoanID: loanID,
			Field:  field,
			Value:  value,
			Reason: ReasonInvalidDate,
		}
	}
	return isValidDate, nil
}

func calculateLateFee(overdueDays int) int {
	if overdueDays <= 0 {
		return 0
	}

	fee := overdueDays * lateFeePerDay
	if fee > maximumLateFee {
		return maximumLateFee
	}

	return fee
}

func evaluateLoan(
	current Loan,
	asOf time.Time,
) (LoanDecision, error) {
	if strings.TrimSpace(current.ID) == "" {
		return LoanDecision{}, &ValidationError{
			LoanID: current.ID,
			Field:  "id",
			Value:  current.ID,
			Reason: ReasonRequired,
		}
	}
	if strings.TrimSpace(current.Title) == "" {
		return LoanDecision{}, &ValidationError{
			LoanID: current.ID,
			Field:  "title",
			Value:  current.Title,
			Reason: ReasonRequired,
		}
	}
	borrowedDate, err := parseDate(current.BorrowedOn, "borrowed_on", current.ID)
	if err != nil {
		return LoanDecision{}, err
	}
	dueDate, err := parseDate(current.DueOn, "due_on", current.ID)
	if err != nil {
		return LoanDecision{}, err
	}
	if dueDate.Before(borrowedDate) {
		return LoanDecision{}, &ValidationError{
			LoanID: current.ID,
			Field:  "due_on",
			Value:  current.DueOn,
			Reason: ReasonBeforeBorrowed,
		}
	}
	if current.ReturnedOn == "" {
		if asOf.After(dueDate) {
			days := int(asOf.Sub(dueDate).Hours() / 24)
			return LoanDecision{
				LoanID:      current.ID,
				Title:       current.Title,
				State:       LoanStateOverdue,
				OverdueDays: days,
				LateFee:     calculateLateFee(days),
			}, nil
		}
		return LoanDecision{
			LoanID:      current.ID,
			Title:       current.Title,
			State:       LoanStateActive,
			OverdueDays: 0,
			LateFee:     0,
		}, nil
	}

	returnedDate, err := parseDate(current.ReturnedOn, "returned_on", current.ID)
	if err != nil {
		return LoanDecision{}, err
	}
	if returnedDate.Before(borrowedDate) {
		return LoanDecision{}, &ValidationError{
			LoanID: current.ID,
			Field:  "returned_on",
			Value:  current.ReturnedOn,
			Reason: ReasonBeforeBorrowed,
		}
	}
	if returnedDate.After(asOf) {
		return LoanDecision{}, &ValidationError{
			LoanID: current.ID,
			Field:  "returned_on",
			Value:  current.ReturnedOn,
			Reason: ReasonAfterAsOf,
		}
	}

	days := 0
	if returnedDate.After(dueDate) {
		days = int(returnedDate.Sub(dueDate).Hours() / 24)
	}

	return LoanDecision{
		LoanID:      current.ID,
		Title:       current.Title,
		State:       LoanStateReturned,
		OverdueDays: days,
		LateFee:     calculateLateFee(days),
	}, nil
}

func BuildReport(loans []Loan, asOf string) (Report, error) {
	asOfDate, err := time.Parse(DateLayout, asOf)
	if err != nil {
		return Report{}, &ValidationError{
			LoanID: "",
			Field:  "as_of",
			Value:  asOf,
			Reason: ReasonInvalidDate,
		}
	}
	report := Report{
		Decisions:     make([]LoanDecision, 0, len(loans)),
		ActiveCount:   0,
		ReturnedCount: 0,
		OverdueCount:  0,
		TotalLateFees: 0,
	}
	seenIDs := make(map[string]struct{}, len(loans))
	for _, current := range loans {
		decision, err := evaluateLoan(current, asOfDate)
		if err != nil {
			return Report{}, err
		}
		if _, exists := seenIDs[current.ID]; exists {
			return Report{}, &ValidationError{
				LoanID: current.ID,
				Field:  "id",
				Value:  current.ID,
				Reason: ReasonDuplicateLoanID,
			}
		}
		seenIDs[current.ID] = struct{}{}

		report.Decisions = append(report.Decisions, decision)
		switch decision.State {
		case LoanStateActive:
			report.ActiveCount++
		case LoanStateReturned:
			report.ReturnedCount++
		case LoanStateOverdue:
			report.OverdueCount++
		}

		report.TotalLateFees += decision.LateFee
	}

	return report, nil
}
