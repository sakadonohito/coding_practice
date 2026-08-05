<?php

declare(strict_types=1);

namespace App;

final readonly class ExpenseReport
{
  /**
   * @param list<ExpenseDecision> $decisions
   */
  public function __construct(
    public array $decisions,
    public int $totalRequested,
    public int $totalApproved,
    public int $totalUnapproved,
  ) {
  }
}
