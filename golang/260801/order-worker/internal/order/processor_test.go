package order_test

import (
	"context"
	"errors"
	"example.com/order-worker/internal/order"
	"strings"
	"sync"
	"testing"
	"time"
)

type fakeCalculator struct {
	mu        sync.Mutex
	active    int
	maxActive int
	started   chan string
	release   chan struct{}
	results   map[string]order.Summary
	errors    map[string]error
}

func (f *fakeCalculator) Calculate(
	ctx context.Context,
	input order.Order,
) (order.Summary, error) {
	f.mu.Lock()
	f.active++
	if f.active > f.maxActive {
		f.maxActive = f.active
	}
	f.mu.Unlock()

	defer func() {
		f.mu.Lock()
		f.active--
		f.mu.Unlock()
	}()

	if f.started != nil {
		select {
		case f.started <- input.ID:
		case <-ctx.Done():
			return order.Summary{}, ctx.Err()
		}
	}

	if f.release != nil {
		select {
		case <-f.release:
		case <-ctx.Done():
			return order.Summary{}, ctx.Err()
		}
	}

	if err := f.errors[input.ID]; err != nil {
		return order.Summary{}, err
	}

	return f.results[input.ID], nil
}

func TestTaxCalculatorCalculate(t *testing.T) {
	tests := []struct {
		name         string
		input        order.Order
		wantSubtotal int64
		wantTax      int64
		wantTotal    int64
	}{
		{
			name: "10パーセントの税を計算する",
			input: order.Order{
				ID: "ORD-001", UnitPrice: 1200, Quantity: 2,
			},
			wantSubtotal: 2400,
			wantTax:      240,
			wantTotal:    2640,
		},
		{
			name: "1円未満を切り捨てる",
			input: order.Order{
				ID: "ORD-002", UnitPrice: 101, Quantity: 1,
			},
			wantSubtotal: 101,
			wantTax:      10,
			wantTotal:    111,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 要件:
			// 税率10のTaxCalculatorを作成する。
			// Calculateへtt.inputを渡す。
			// エラーがないことを確認する。
			// Subtotal、Tax、Totalが期待値と一致することを確認する。
			calculator, err := order.NewTaxCalculator(10)
			if err != nil {
				t.Fatalf("unexpected error creating calculator: %v", err)
			}
			got, err := calculator.Calculate(context.Background(), tt.input)
			if err != nil {
				t.Fatalf("unexpected error calculating tax: %v", err)
			}

			if got.Subtotal != tt.wantSubtotal {
				t.Errorf("Subtotal = %d, want %d", got.Subtotal, tt.wantSubtotal)
			}
			if got.Tax != tt.wantTax {
				t.Errorf("Tax = %d, want %d", got.Tax, tt.wantTax)
			}
			if got.Total != tt.wantTotal {
				t.Errorf("Total = %d, want %d", got.Total, tt.wantTotal)
			}
		})
	}
}

func TestTaxCalculatorRejectsInvalidOrder(t *testing.T) {
	tests := []struct {
		name  string
		input order.Order
	}{
		{
			name:  "注文IDが空",
			input: order.Order{UnitPrice: 100, Quantity: 1},
		},
		{
			name:  "単価が0",
			input: order.Order{ID: "ORD-001", Quantity: 1},
		},
		{
			name:  "数量が0",
			input: order.Order{ID: "ORD-001", UnitPrice: 100},
		},
	}

	calculator, err := order.NewTaxCalculator(10)
	if err != nil {
		t.Fatalf("unexpected error creating calculator: %v", err)
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 要件:
			// Calculateを実行する。
			// エラーが発生することを確認する。
			// errors.Is(err, order.ErrInvalidOrder)がtrueであることを確認する。
			_, err := calculator.Calculate(context.Background(), tt.input)

			// 2. エラーが発生すること（err != nil）を確認する
			if err == nil {
				t.Fatalf("expected error, got nil")
			}

			// 3. errors.Is(err, order.ErrInvalidOrder) が true であることを確認する
			if !errors.Is(err, order.ErrInvalidOrder) {
				t.Errorf("error = %v, want errors.Is(ErrInvalidOrder)", err)
			}

		})
	}
}

func TestProcessorPreservesInputOrder(t *testing.T) {
	// 要件:
	// ORD-001、ORD-002、ORD-003の3注文を用意する。
	// fakeCalculatorへ各注文のSummaryを設定する。
	// workerCount=3でProcessを実行する。
	// 返されたSummaryのOrderIDが入力順と同じであることを確認する。
	// 完了順に依存するsleepは使わない。
	orders := []order.Order{
		{ID: "ORD-001", UnitPrice: 1200, Quantity: 2},
		{ID: "ORD-002", UnitPrice: 500, Quantity: 3},
		{ID: "ORD-003", UnitPrice: 9800, Quantity: 1},
	}
	calc := &fakeCalculator{
		results: map[string]order.Summary{
			"ORD-001": {OrderID: "ORD-001", Subtotal: 2400, Tax: 240, Total: 2640},
			"ORD-002": {OrderID: "ORD-002", Subtotal: 1500, Tax: 150, Total: 1650},
			"ORD-003": {OrderID: "ORD-003", Subtotal: 9800, Tax: 980, Total: 10780},
		},
	}
	processor := order.NewProcessor(calc)
	summaries, err := processor.Process(context.Background(), orders, 3)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	for i, currentOrder := range orders {
		if summaries[i].OrderID != currentOrder.ID {
			t.Errorf("summaries[%d].OrderID = %q, want %q", i, summaries[i].OrderID, currentOrder.ID)
		}
	}
}

func TestProcessorLimitsConcurrency(t *testing.T) {
	// 要件:
	// startedとreleaseを持つfakeCalculatorを用意する。
	// 5件の注文をworkerCount=2で別goroutineから処理する。
	// startedから2件の開始を受信する。
	// 2件を解放する前に3件目が開始されないことを確認する。
	// releaseを閉じ、Processの完了を待つ。
	// fakeCalculator.maxActiveが2であることを確認する。
	// テストを永久停止させないため、待機にはcontextのtimeoutを使う。
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	calc := &fakeCalculator{
		started: make(chan string, 5),
		release: make(chan struct{}),
		results: map[string]order.Summary{
			"ORD-001": {OrderID: "ORD-001"},
			"ORD-002": {OrderID: "ORD-002"},
			"ORD-003": {OrderID: "ORD-003"},
			"ORD-004": {OrderID: "ORD-004"},
			"ORD-005": {OrderID: "ORD-005"},
		},
	}
	orders := []order.Order{
		{ID: "ORD-001", UnitPrice: 100, Quantity: 1},
		{ID: "ORD-002", UnitPrice: 100, Quantity: 1},
		{ID: "ORD-003", UnitPrice: 100, Quantity: 1},
		{ID: "ORD-004", UnitPrice: 100, Quantity: 1},
		{ID: "ORD-005", UnitPrice: 100, Quantity: 1},
	}
	processor := order.NewProcessor(calc)
	// Process の完了エラーを受け取るためのチャネル
	errCh := make(chan error, 1)
	// 別 goroutine で Process を開始する（workerCount = 2）
	go func() {
		_, err := processor.Process(ctx, orders, 2)
		errCh <- err
	}()

	<-calc.started
	<-calc.started

	select {
	case id := <-calc.started:
		t.Fatalf("3件目が予期せず開始されました: %s", id)
	default:
		// 3件目が開始されていない（成功！）
	}

	// 待機を解除
	close(calc.release)
	// Process の完了を待ち、エラーを検証
	if err := <-errCh; err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	// 最大同時実行数が 2 であったか検証
	if calc.maxActive != 2 {
		t.Errorf("maxActive = %d, want 2", calc.maxActive)
	}

}

func TestProcessorRejectsDuplicateOrderID(t *testing.T) {
	// 要件:
	// IDがともにORD-001の注文を2件用意する。
	// Processを実行する。
	// errors.Is(err, order.ErrDuplicateOrderID)がtrueであることを確認する。
	// fakeCalculatorが呼び出されていないことも確認する。
	orders := []order.Order{
		{ID: "ORD-001", UnitPrice: 1000, Quantity: 1},
		{ID: "ORD-001", UnitPrice: 2000, Quantity: 1},
	}
	calc := &fakeCalculator{}
	processor := order.NewProcessor(calc)
	_, err := processor.Process(context.Background(), orders, 2)
	if err == nil {
		t.Fatalf("expected error, got nil")
	}
	if !errors.Is(err, order.ErrDuplicateOrderID) {
		t.Errorf("error = %v, want errors.Is(ErrDuplicateOrderID)", err)
	}

	if calc.maxActive != 0 {
		t.Errorf("maxActive = %d, want 0 (calculator should not be called)", calc.maxActive)
	}

}

func TestProcessorWrapsCalculatorErrorWithOrderID(t *testing.T) {
	// 要件:
	// 独自のsentinel errorを作る。
	// ORD-002に対してそのエラーを返すfakeCalculatorを用意する。
	// Processを実行する。
	// errors.Isで元のsentinel errorを取得できることを確認する。
	// エラーメッセージにORD-002が含まれることを確認する。
	errCustom := errors.New("custom calculation error")
	calc := &fakeCalculator{
		errors: map[string]error{
			"ORD-002": errCustom,
		},
	}
	orders := []order.Order{
		{ID: "ORD-001", UnitPrice: 100, Quantity: 1},
		{ID: "ORD-002", UnitPrice: 100, Quantity: 1},
	}
	processor := order.NewProcessor(calc)
	_, err := processor.Process(context.Background(), orders, 2)

	if err == nil {
		t.Fatalf("expected error, got nil")
	}
	if !errors.Is(err, errCustom) {
		t.Errorf("error = %v, want errors.Is(errCustom)", err)
	}
	if !strings.Contains(err.Error(), "ORD-002") {
		t.Errorf("error message %q does not contain %q", err.Error(), "ORD-002")
	}

}

func TestProcessorReturnsContextError(t *testing.T) {
	// 要件:
	// 開始前にcancel済みのcontextを用意する。
	// Processを実行する。
	// errors.Is(err, context.Canceled)がtrueであることを確認する。
	ctx, cancel := context.WithCancel(context.Background())
	cancel() // ★ 呼び出す前に事前キャンセル！

	orders := []order.Order{
		{ID: "ORD-001", UnitPrice: 1000, Quantity: 1},
	}
	calc := &fakeCalculator{}
	processor := order.NewProcessor(calc)
	_, err := processor.Process(ctx, orders, 1)

	if err == nil {
		t.Fatalf("expected error, got nil")
	}
	if !errors.Is(err, context.Canceled) {
		t.Errorf("error = %v, want errors.Is(context.Canceled)", err)
	}

}

// 空実装中でもimportの目的が分かるように残してあります。
var (
	_ = errors.Is
	_ = sync.Mutex{}
)
