package inventory

import (
    "errors"
    "reflect"
    "testing"
)

func TestNewInventoryAndFind(t *testing.T) {
    inv, err := NewInventory([]Product{
        {ID: "P-001", Name: "ノート", Stock: 5},
        {ID: "P-002", Name: "ペン", Stock: 0},
    })
    if err != nil {
        t.Fatalf("NewInventory() error = %v", err)
    }

    got, ok := inv.Find("P-001")
    if !ok {
        t.Fatal("Find(P-001) ok = false, want true")
    }
    want := Product{ID: "P-001", Name: "ノート", Stock: 5}
    if got != want {
        t.Errorf("Find(P-001) = %#v, want %#v", got, want)
    }

    missing, ok := inv.Find("P-999")
    if ok {
        t.Fatal("Find(P-999) ok = true, want false")
    }
    if missing != (Product{}) {
        t.Errorf("Find(P-999) = %#v, want zero value", missing)
    }
}

func TestNewInventoryRejectsInvalidProducts(t *testing.T) {
    tests := []struct {
        name     string
        products []Product
        wantErr  error
    }{
        {
            name: "空白の商品ID",
            products: []Product{
                {ID: "   ", Name: "ノート", Stock: 1},
            },
            wantErr: ErrInvalidProduct,
        },
        {
            name: "空白の商品名",
            products: []Product{
                {ID: "P-001", Name: "  ", Stock: 1},
            },
            wantErr: ErrInvalidProduct,
        },
        {
            name: "負の在庫",
            products: []Product{
                {ID: "P-001", Name: "ノート", Stock: -1},
            },
            wantErr: ErrInvalidProduct,
        },
        {
            name: "商品IDの重複",
            products: []Product{
                {ID: "P-001", Name: "ノート", Stock: 1},
                {ID: "P-001", Name: "別のノート", Stock: 2},
            },
            wantErr: ErrDuplicateProductID,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := NewInventory(tt.products)
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("error = %v, want errors.Is(..., %v)", err, tt.wantErr)
            }
        })
    }
}

func TestAddStock(t *testing.T) {
    inv, err := NewInventory([]Product{
        {ID: "P-001", Name: "ノート", Stock: 5},
    })
    if err != nil {
        t.Fatalf("NewInventory() error = %v", err)
    }

    if err := inv.AddStock("P-001", 3); err != nil {
        t.Fatalf("AddStock() error = %v", err)
    }

    got, _ := inv.Find("P-001")
    if got.Stock != 8 {
        t.Errorf("Stock = %d, want 8", got.Stock)
    }
}

func TestRemoveStock(t *testing.T) {
    inv, err := NewInventory([]Product{
        {ID: "P-001", Name: "ノート", Stock: 5},
    })
    if err != nil {
        t.Fatalf("NewInventory() error = %v", err)
    }

    if err := inv.RemoveStock("P-001", 2); err != nil {
        t.Fatalf("RemoveStock() error = %v", err)
    }

    got, _ := inv.Find("P-001")
    if got.Stock != 3 {
        t.Errorf("Stock = %d, want 3", got.Stock)
    }
}

func TestRemoveStockKeepsStockWhenInsufficient(t *testing.T) {
    inv, err := NewInventory([]Product{
        {ID: "P-001", Name: "ノート", Stock: 3},
    })
    if err != nil {
        t.Fatalf("NewInventory() error = %v", err)
    }

    err = inv.RemoveStock("P-001", 4)
    if !errors.Is(err, ErrInsufficientStock) {
        t.Fatalf("error = %v, want ErrInsufficientStock", err)
    }

    got, _ := inv.Find("P-001")
    if got.Stock != 3 {
        t.Errorf("Stock after error = %d, want 3", got.Stock)
    }
}

func TestStockOperationsRejectInvalidInput(t *testing.T) {
    inv, err := NewInventory([]Product{
        {ID: "P-001", Name: "ノート", Stock: 3},
    })
    if err != nil {
        t.Fatalf("NewInventory() error = %v", err)
    }

    tests := []struct {
        name    string
        run     func() error
        wantErr error
    }{
        {
            name: "未登録商品への入荷",
            run: func() error {
                return inv.AddStock("P-999", 1)
            },
            wantErr: ErrUnknownProduct,
        },
        {
            name: "未登録商品の出庫",
            run: func() error {
                return inv.RemoveStock("P-999", 1)
            },
            wantErr: ErrUnknownProduct,
        },
        {
            name: "入荷数が0",
            run: func() error {
                return inv.AddStock("P-001", 0)
            },
            wantErr: ErrInvalidQuantity,
        },
        {
            name: "出庫数が負数",
            run: func() error {
                return inv.RemoveStock("P-001", -1)
            },
            wantErr: ErrInvalidQuantity,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := tt.run()
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("error = %v, want errors.Is(..., %v)", err, tt.wantErr)
            }
        })
    }
}

func TestSummary(t *testing.T) {
    inv, err := NewInventory([]Product{
        {ID: "P-001", Name: "ノート", Stock: 5},
        {ID: "P-002", Name: "ペン", Stock: 0},
        {ID: "P-003", Name: "消しゴム", Stock: 3},
    })
    if err != nil {
        t.Fatalf("NewInventory() error = %v", err)
    }

    got := inv.Summary()
    want := StockSummary{
        ProductKinds:    3,
        TotalUnits:      8,
        OutOfStockKinds: 1,
    }

    if !reflect.DeepEqual(got, want) {
        t.Errorf("Summary() = %#v, want %#v", got, want)
    }
}
