<?php
declare(strict_types=1);

namespace App;

final readonly class ExpenseClaim
{
  public function __construct(
    public string $claimId,
    public string $description,
    public ExpenseCategory $category,
    public int $amount,
    public bool $hasReceipt,
  ) {
  }
}
