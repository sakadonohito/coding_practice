<?php

declare(strict_types=1);

namespace App;

use DomainException;

final class ReimbursementService
{
  private const int RECEIPT_REQUIRED_OVER = 5_000;

  /**
   * @param list<ExpenseClaim> $claims
   */
  #[\NoDiscard(
    message:'精算結果を受け取ってください',
  )]
  public function review(array $claims): ExpenseReport
  {
    $this->validateClaims($claims);
    $decisions = [];
    $totalRequested = 0;
    $totalApproved = 0;
    $totalUnapproved = 0;
    foreach ($claims as $claim) {
      $decision = $this->reviewClaim($claim);
      $decisions[] = $decision;
      $totalRequested += $decision->requestedAmount;
      $totalApproved += $decision->approvedAmount;
      $totalUnapproved += $decision->unapprovedAmount;
    }
    return new ExpenseReport(
      $decisions, $totalRequested, $totalApproved, $totalUnapproved
    );
  }

  /**
   * @param list<ExpenseClaim> $claims
   */
  private function validateClaims(array $claims): void
  {
    $seenIds = [];
    foreach ($claims as $claim) {
      if (trim($claim->claimId) === '') {
        throw new DomainException("Claim ID must not be blank");
      }
      if (trim($claim->description) === '') {
        throw new DomainException("Description must not be blank: {$claim->claimId}");
      }
      if ($claim->amount < 1) {
        throw new DomainException("Amount must be at least 1: {$claim->claimId} = {$claim->amount}");
      }
      if (isset($seenIds[$claim->claimId])) {
        throw new DomainException("Duplicate claim ID: {$claim->claimId}");
      }
      $seenIds[$claim->claimId] = true;
    }
  }

  private function reviewClaim(
    ExpenseClaim $claim,
  ): ExpenseDecision {
    if ($claim->amount > $this::RECEIPT_REQUIRED_OVER && !$claim->hasReceipt) {
      return new ExpenseDecision(
        $claim->claimId,
        $claim->amount,
        0,
        $claim->amount,
        RejectionReason::MissingReceipt,
      );
    }
    $limit = $claim->category->approvalLimit();
    $approvedAmount = min($claim->amount, $limit);
    $unapprovedAmount = $claim->amount - $approvedAmount;
    $reason = ($unapprovedAmount === 0) ? null : RejectionReason::OverCategoryLimit;

    return new ExpenseDecision(
      $claim->claimId,
      $claim->amount,
      $approvedAmount,
      $unapprovedAmount,
      $reason,
    );
  }
}
