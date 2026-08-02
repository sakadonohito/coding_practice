package order

import (
	"context"
	"errors"
	"fmt"
)

var ErrInvalidOrder = errors.New("invalid order")

type Order struct {
	ID        string
	UnitPrice int64
	Quantity  int64
}

type Summary struct {
	OrderID  string
	Subtotal int64
	Tax      int64
	Total    int64
}

type Calculator interface {
	Calculate(ctx context.Context, order Order) (Summary, error)
}

type TaxCalculator struct {
	taxRate int64
}

func NewTaxCalculator(taxRate int64) (*TaxCalculator, error) {
	if taxRate < 0 || taxRate > 100 {
		return nil, fmt.Errorf(
			"%w: tax rate must be between 0 and 100",
			ErrInvalidOrder,
		)
	}

	return &TaxCalculator{taxRate: taxRate}, nil
}

func (c *TaxCalculator) Calculate(
	ctx context.Context,
	order Order,
) (Summary, error) {
	if err := ctx.Err(); err != nil {
		return Summary{}, err
	}

	if order.ID == "" {
		return Summary{}, fmt.Errorf(
			"%w: order ID must not be empty",
			ErrInvalidOrder,
		)
	}
	if order.UnitPrice <= 0 {
		return Summary{}, fmt.Errorf(
			"%w: unit price must be greater than zero",
			ErrInvalidOrder,
		)
	}
	if order.Quantity <= 0 {
		return Summary{}, fmt.Errorf(
			"%w: quantity must be greater than zero",
			ErrInvalidOrder,
		)
	}

	subtotal := order.UnitPrice * order.Quantity
	tax := subtotal * c.taxRate / 100

	return Summary{
		OrderID:  order.ID,
		Subtotal: subtotal,
		Tax:      tax,
		Total:    subtotal + tax,
	}, nil
}
