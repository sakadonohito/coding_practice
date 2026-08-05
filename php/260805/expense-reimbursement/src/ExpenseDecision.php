<?php
declare(strict_types=1);

namespace App;

enum RejectionReason: string
{
  case MissingReceipt = 'missing-receipt';
  case OverCategoryLimit = 'over-category-limit';
}

final readonly class ExpenseDecision
{
  public function __construct(
    public string $claimId,
    public int $requestedAmount,
    public int $approvedAmount,
    public int $unapprovedAmount,
    public ?RejectionReason $reason,
  ) {
  }
}
