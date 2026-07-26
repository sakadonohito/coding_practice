package main

import "testing"

func TestTotalByCategory(t *testing.T) {
	// 次の支出データを用意してください。
	// food: 1200
	// book: 2500
	// food: 800
	// transport: 500
	expenses := []Expense{
		{Category: "food", Amount: 1200},
		{Category: "book", Amount: 2500},
		{Category: "food", Amount: 800},
		{Category: "transport", Amount: 500},
	}
	// TotalByCategory を呼び出してください。
	results := TotalByCategory(expenses)

	// 以下を検証してください。
	// food の合計が 2000 であること
	// book の合計が 2500 であること
	// transport の合計が 500 であること
	// 存在するカテゴリ数が 3 であること
	expected := map[string]int{
		"food": 2000,
		"book": 2500,
		"transport": 500,
	}

	if len(results) != len(expected) {
		t.Errorf("期待されるマップの要素数と一致しません。期待値: %d, 実際: %d", len(expected), len(results))
	}

	for k, v := range expected {
		if actualV, ok := results[k]; !ok || actualV != v {
			t.Errorf("カテゴリ %s の値が期待値 %d と異なります。実際: %d", k, v, actualV)
		}
	}

}
