package main

import (
	"context"
	"example.com/order-worker/internal/order"
	"fmt"
	"log"
)

func main() {
	calculator, err := order.NewTaxCalculator(10)
	if err != nil {
		log.Fatal(err)
	}

	processor := order.NewProcessor(calculator)
	orders := []order.Order{
		{ID: "ORD-001", UnitPrice: 1200, Quantity: 2},
		{ID: "ORD-002", UnitPrice: 500, Quantity: 3},
		{ID: "ORD-003", UnitPrice: 9800, Quantity: 1},
	}

	summaries, err := processor.Process(
		context.Background(),
		orders,
		2,
	)
	if err != nil {
		log.Fatal(err)
	}

	for _, summary := range summaries {
		fmt.Printf(
			"%s: subtotal=%d tax=%d total=%d\n",
			summary.OrderID,
			summary.Subtotal,
			summary.Tax,
			summary.Total,
		)
	}
}
