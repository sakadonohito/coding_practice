package main

import "fmt"

type Order struct {
	ID        string
	Customer  string
	TotalYen  int
	IsShipped bool
}

func UnshippedOrderIDs(orders []Order) []string {
	result := []string{}

	for _, order := range orders {
		if !order.IsShipped {
			result = append(result, order.ID)
		}
	}

	return result
}

func main() {
	orders := []Order{
		{ID: "ORD-001", Customer: "田中", TotalYen: 3200, IsShipped: true},
		{ID: "ORD-002", Customer: "佐藤", TotalYen: 5400, IsShipped: false},
		{ID: "ORD-003", Customer: "鈴木", TotalYen: 1800, IsShipped: false},
	}

	ids := UnshippedOrderIDs(orders)

	fmt.Println(ids)
}
