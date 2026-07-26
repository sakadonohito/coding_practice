package main

import (
	"fmt"
)

type Expense struct {
	Category string
	Amount   int
}

func TotalByCategory(expenses []Expense) map[string]int {
	totals := make(map[string]int)

	for _, expense := range expenses {
		totals[expense.Category] += expense.Amount
	}

	return totals
}

func main() {
	expenses := []Expense{
		{Category: "food", Amount: 1200},
		{Category: "book", Amount: 2500},
		{Category: "food", Amount: 800},
		{Category: "transport", Amount: 500},
	}

	totals := TotalByCategory(expenses)

	fmt.Println(totals)
}
