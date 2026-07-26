package order

import "testing"

func TestCalculateTotal(t *testing.T) {
	t.Run("複数の商品から合計金額を計算できる", func(t *testing.T) {
		// 1. Price と Quantity が異なる商品を2件以上用意してください。
		items := []OrderItem{
			{Name: "ノート", Price: 120, Quantity: 2},
			{Name: "ペン", Price: 80, Quantity: 3},
		}
		// 2. CalculateTotal を呼び出してください。
		got := CalculateTotal(items)
		// 3. 期待した合計金額になることを確認してください。
		want := 120 * 2 + 80 * 3
		if got != want {
			t.Errorf("CalculateTotal() = %v, want %v", got, want)
		}
	})

	t.Run("空の注文一覧なら0を返す", func(t *testing.T) {
		// 1. 空の []OrderItem を用意してください。
		items := []OrderItem{}
		// 2. CalculateTotal を呼び出してください。
		got := CalculateTotal(items)
		// 3. 結果が 0 になることを確認してください。
		want := 0
		if got != want {
			t.Errorf("CalculateTotal() is not 0 => got: %v", got)
		}
	})
}
