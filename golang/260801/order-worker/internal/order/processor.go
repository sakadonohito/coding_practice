package order

import (
	"context"
	"errors"
	"fmt"
	"sync"
)

var (
	ErrInvalidWorkerCount = errors.New("invalid worker count")
	ErrDuplicateOrderID   = errors.New("duplicate order ID")
)

type Processor struct {
	calculator Calculator
}

func NewProcessor(calculator Calculator) *Processor {
	return &Processor{calculator: calculator}
}

type job struct {
	index int
	order Order
}

type result struct {
	index   int
	summary Summary
	err     error
}

func (p *Processor) Process(
	ctx context.Context,
	orders []Order,
	workerCount int,
) ([]Summary, error) {
	if workerCount < 1 {
		return nil, ErrInvalidWorkerCount
	}
	if err := validateUniqueOrderIDs(orders); err != nil {
		return nil, err
	}
	if len(orders) == 0 {
		return []Summary{}, nil
	}

	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	jobs := make(chan job)
	results := make(chan result)

	var workers sync.WaitGroup
	workers.Add(workerCount)

	for range workerCount {
		go func() {
			defer workers.Done()
			p.worker(ctx, jobs, results)
		}()
	}
	go func() {
		defer close(jobs)
		for index, currentOrder := range orders {
			select {
			case jobs <- job{index: index, order: currentOrder}:
			case <-ctx.Done():
				return
			}
		}
	}()

	go func() {
		workers.Wait()
		close(results)
	}()

	summaries := make([]Summary, len(orders))
	completed := 0

	for currentResult := range results {
		if currentResult.err != nil {
			cancel()
			return nil, fmt.Errorf(
				"process order %q: %w",
				orders[currentResult.index].ID,
				currentResult.err,
			)
		}
		summaries[currentResult.index] = currentResult.summary
		completed++
	}

	if completed != len(orders) {
		return nil, ctx.Err()
	}

	return summaries, nil
}

func (p *Processor) worker(
	ctx context.Context,
	jobs <-chan job,
	results chan<- result,
) {
	for currentJob := range jobs {
		summary, err := p.calculator.Calculate(
			ctx,
			currentJob.order,
		)

		select {
		case results <- result{
			index:   currentJob.index,
			summary: summary,
			err:     err,
		}:
		case <-ctx.Done():
			return
		}

		if err != nil {
			return
		}
	}
}

func validateUniqueOrderIDs(orders []Order) error {
	seen := make(map[string]struct{}, len(orders))

	for _, currentOrder := range orders {
		if _, exists := seen[currentOrder.ID]; exists {
			return fmt.Errorf(
				"%w: %q",
				ErrDuplicateOrderID,
				currentOrder.ID,
			)
		}
		seen[currentOrder.ID] = struct{}{}
	}

	return nil
}
