// Package inventory provides product inventory management.
package inventory

import (
	"errors"
	"fmt"
	"strings"
)

var (
	ErrInvalidProduct     = errors.New("invalid product")
	ErrDuplicateProductID = errors.New("duplicate product ID")
	ErrUnknownProduct     = errors.New("unknown product")
	ErrInvalidQuantity    = errors.New("invalid quantity")
	ErrInsufficientStock  = errors.New("insufficient stock")
)

type Product struct {
	ID    string
	Name  string
	Stock int
}

type StockSummary struct {
	ProductKinds    int
	TotalUnits      int
	OutOfStockKinds int
}

type Inventory struct {
	products map[string]Product
}

func NewInventory(products []Product) (*Inventory, error) {
	productsByID := make(map[string]Product)
	for _, product := range products {
		if strings.TrimSpace(product.ID) == "" {
			return nil, fmt.Errorf("%w: name must not be blank: %s", ErrInvalidProduct, product.ID)
		}
		if strings.TrimSpace(product.Name) == "" {
			return nil, fmt.Errorf("%w: name must not be blank: %s", ErrInvalidProduct, product.ID)
		}
		if product.Stock < 0 {
			return nil, fmt.Errorf("%w: stock must be non-negative, %s = %d", ErrInvalidProduct, product.ID, product.Stock)
		}
		if _, ok := productsByID[product.ID]; ok {
			return nil, fmt.Errorf("%w: %s", ErrDuplicateProductID, product.ID)
		}
		productsByID[product.ID] = product
	}
	return &Inventory{products: productsByID}, nil
}

func (i *Inventory) Find(productID string) (Product, bool) {
	// Inventory のメソッド的な
	product, ok := i.products[productID]
	return product, ok
}

func (i *Inventory) AddStock(productID string, quantity int) error {
	if quantity < 1 {
		return fmt.Errorf("%w: quantity must be at least 1: %d", ErrInvalidQuantity, quantity)
	}
	product, ok := i.products[productID]
	if !ok {
		return fmt.Errorf("%w: unknown product ID: %s", ErrUnknownProduct, productID)
	}
	product.Stock += quantity
	i.products[productID] = product
	return nil
}

func (i *Inventory) RemoveStock(productID string, quantity int) error {
	if quantity < 1 {
		return fmt.Errorf("%w: quantity must be at least 1: %d", ErrInvalidQuantity, quantity)
	}
	product, ok := i.products[productID]
	if !ok {
		return fmt.Errorf("%w: unknown product ID: %s", ErrUnknownProduct, productID)
	}
	if product.Stock < quantity {
		return fmt.Errorf("%w: insufficient stock for product %s (stock %d, requested %d)", ErrInsufficientStock, productID, product.Stock, quantity)
	}
	product.Stock -= quantity
	i.products[productID] = product
	return nil
}

func (i *Inventory) Summary() StockSummary {
	kinds := len(i.products)
	var totalUnit = 0
	var zeroUnit = 0
	for _, p := range i.products {
		totalUnit += p.Stock
		if p.Stock == 0 {
			zeroUnit++
		}
	}

	return StockSummary{
		ProductKinds:    kinds,
		TotalUnits:      totalUnit,
		OutOfStockKinds: zeroUnit,
	}
}
