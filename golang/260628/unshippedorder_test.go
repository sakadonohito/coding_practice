package main

import (
	"slices"
	"testing"
)

func TestUnshippedOrderIDs(t *testing.T) {
	tests := []struct {
		name   string
		orders []Order
		want   []string
	}{
		{
			name: "発送済み注文と未発送注文が混ざっている場合、未発送注文のIDだけを返す",
			orders: []Order{
				{ID: "ORD-001", Customer: "田中", TotalYen: 3200, IsShipped: true},
				{ID: "ORD-002", Customer: "佐藤", TotalYen: 5400, IsShipped: false},
				{ID: "ORD-003", Customer: "鈴木", TotalYen: 1800, IsShipped: false},
			},
			want: []string{"ORD-002", "ORD-003"},
		},
		{
			name: "すべて発送済みの場合、空スライスを返す",
			orders: []Order{
				{ID: "ORD-001", Customer: "田中", TotalYen: 3200, IsShipped: true},
				{ID: "ORD-002", Customer: "佐藤", TotalYen: 5400, IsShipped: true},
				{ID: "ORD-003", Customer: "鈴木", TotalYen: 1800, IsShipped: true},
			},
			want: []string{},
		},
		{
			name:   "注文一覧が空の場合、空スライスを返す",
			orders: []Order{},
			want:   []string{},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := UnshippedOrderIDs(tt.orders)

			if !slices.Equal(got, tt.want) {
				t.Errorf("UnshippedOrderIDs() = %v, want %v", got, tt.want)
			}

		})
	}
}

//package main
//
//import (
//	"reflect"
//	"slices"
//	"testing"
//)
//
//func TestUnshippedOrderIDs_ReturnsOnlyUnshippedOrders(t *testing.T) {
//	// 1. 発送済み注文と未発送注文が混ざった orders を用意してください。
//	orders := []Order{
//		{ID: "ORD-001", Customer: "田中", TotalYen: 3200, IsShipped: true},
//		{ID: "ORD-002", Customer: "佐藤", TotalYen: 5400, IsShipped: false},
//		{ID: "ORD-003", Customer: "鈴木", TotalYen: 1800, IsShipped: false},
//	}
//	// 2. UnshippedOrderIDs を呼び出してください。
//	got := UnshippedOrderIDs(orders)
//	// 3. 未発送注文のIDだけが返ることを検証してください。
//	want := []string{"ORD-002", "ORD-003"}
//	if !reflect.DeepEqual(got, want) {
//		t.Errorf("内容が一致しません: UnshippedOrderIDs() = %v, want %v", got, want)
//	}
//}
//
//func TestUnshippedOrderIDs_ReturnsEmptySliceWhenAllOrdersAreShipped(t *testing.T) {
//	// 1. すべて IsShipped: true の orders を用意してください。
//	orders := []Order{
//		{ID: "ORD-001", Customer: "田中", TotalYen: 3200, IsShipped: true},
//		{ID: "ORD-002", Customer: "佐藤", TotalYen: 5400, IsShipped: true},
//		{ID: "ORD-003", Customer: "鈴木", TotalYen: 1800, IsShipped: true},
//	}
//	// 2. UnshippedOrderIDs を呼び出してください。
//	got := UnshippedOrderIDs(orders)
//	// 3. 結果が空スライスになることを検証してください。
//	want := []string{}
//	if !slices.Equal(got, want) {
//		t.Errorf("空を期待したのに...: UnshippedOrderIDs() = %v, want %v", got, want)
//	}
//}
//
//func TestUnshippedOrderIDs_ReturnsEmptySliceWhenOrdersIsEmpty(t *testing.T) {
//	// 1. 空の orders を用意してください。
//	orders := []Order{}
//	// 2. UnshippedOrderIDs を呼び出してください。
//	got := UnshippedOrderIDs(orders)
//	// 3. 結果が空スライスになることを検証してください。
//	want := []string{}
//	if !slices.Equal(got, want) {
//		t.Errorf("空を期待したのに...: UnshippedOrderIDs() = %v, want %v", got, want)
//	}
//}
