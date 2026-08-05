<?php

declare(strict_types=1);

namespace Tests;

use App\ExpenseCategory;
use App\ExpenseClaim;
use App\ExpenseReport;
use App\ReimbursementService;
use App\RejectionReason;
use DomainException;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

final class ReimbursementServiceTest extends TestCase
{
    #[Test]
    public function 複数の申請を判定して集計できる(): void
    {
      $claims = [
        new ExpenseClaim('EXP-001', '交通費', ExpenseCategory::Travel, 12_000, true),
        new ExpenseClaim('EXP-002', '食費', ExpenseCategory::Meal, 4_200, true),
        new ExpenseClaim('EXP-003', '備品費', ExpenseCategory::Supplies, 8_000, true),
      ];

      $service = new ReimbursementService();
      $report = $service->review($claims);

      self::assertSame(24_200, $report->totalRequested);
      self::assertSame(23_000, $report->totalApproved);
      self::assertSame(1_200, $report->totalUnapproved);
      self::assertSame(3, count($report->decisions));
      self::assertSame(RejectionReason::OverCategoryLimit, $report->decisions[1]->reason);
    }

    #[Test]
    #[DataProvider('categoryLimitProvider')]
    public function カテゴリ上限を適用する(
        ExpenseCategory $category,
        int $amount,
        int $expectedApproved,
        int $expectedUnapproved,
    ): void {
        /*
         * Providerの値から1件の申請を作る。
         * 領収書はtrue。
         * 先頭decisionのapprovedAmountと
         * unapprovedAmountを確認する。
         */
      $claims = [
        new ExpenseClaim('EXP-001', 'テスト申請', $category, $amount, true),
      ];
      $service = new ReimbursementService();
      $report = $service->review($claims);
      $decision = $report->decisions[0];
      $expectedReason = ($expectedUnapproved === 0) ? null : RejectionReason::OverCategoryLimit;

      self::assertSame($amount, $decision->requestedAmount);
      self::assertSame($expectedApproved, $decision->approvedAmount);
      self::assertSame($expectedUnapproved, $decision->unapprovedAmount);
      self::assertSame($expectedReason, $decision->reason);
    }

    public static function categoryLimitProvider(): iterable
    {
        yield '交通費が上限内' => [
            ExpenseCategory::Travel,
            18_000,
            18_000,
            0,
        ];

        yield '交通費が上限超過' => [
            ExpenseCategory::Travel,
            25_000,
            20_000,
            5_000,
        ];

        yield '食費が上限超過' => [
            ExpenseCategory::Meal,
            4_200,
            3_000,
            1_200,
        ];

        yield '備品費が上限と同額' => [
            ExpenseCategory::Supplies,
            10_000,
            10_000,
            0,
        ];
    }

    #[Test]
    public function 五千円を超えて領収書がなければ全額非承認(): void
    {
      $claims = [
        new ExpenseClaim('EXP-001', 'テスト申請', ExpenseCategory::Meal, 5_001, false),
      ];
      $service = new ReimbursementService();
      $report = $service->review($claims);

      self::assertSame(5_001, $report->totalRequested);
      self::assertSame(0, $report->totalApproved);
      self::assertSame(5_001, $report->totalUnapproved);
      self::assertSame(RejectionReason::MissingReceipt, $report->decisions[0]->reason);
    }

    #[Test]
    public function 五千円ちょうどなら領収書なしでも判定を続ける(): void
    {
      $claims = [
        new ExpenseClaim('EXP-001', 'テスト申請', ExpenseCategory::Travel, 5_000, false),
      ];
      $service = new ReimbursementService();
      $report = $service->review($claims);

      self::assertSame(5_000, $report->totalRequested);
      self::assertSame(5_000, $report->totalApproved);
      self::assertSame(0, $report->totalUnapproved);
      self::assertNull($report->decisions[0]->reason);
    }

    #[Test]
    public function 重複した申請IDを拒否する(): void
    {
      $this->expectException(DomainException::class);
      $this->expectExceptionMessage('Duplicate claim ID: EXP-001');

      $claims = [
        new ExpenseClaim('EXP-001', 'テスト申請', ExpenseCategory::Travel, 5_000, true),
        new ExpenseClaim('EXP-001', 'テスト申請', ExpenseCategory::Travel, 5_000, true),
      ];
      $service = new ReimbursementService();
      (void) $service->review($claims);
    }

    #[Test]
    public function 空の申請一覧なら空のレポートを返す(): void
    {
        /*
         * review([])を実行する。
         * 次と等しいことを確認する。
         *
         * new ExpenseReport(
         *     decisions: [],
         *     totalRequested: 0,
         *     totalApproved: 0,
         *     totalUnapproved: 0,
         * )
         */
      $service = new ReimbursementService();
      $report = $service->review([]);
      self::assertSame(0, $report->totalRequested);
      self::assertSame(0, $report->totalApproved);
      self::assertSame(0, $report->totalUnapproved);
      self::assertSame([], $report->decisions);
    }
}
