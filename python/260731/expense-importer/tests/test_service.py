from datetime import date
from decimal import Decimal

import pytest

from expense_importer.errors import (
    DuplicateTransactionError,
)
from expense_importer.models import (
    ExpenseCategory,
    ExpenseRecord,
)
from expense_importer.service import (
    summarize_expenses,
)


def create_record(
    *,
    transaction_id: str,
    category: ExpenseCategory,
    amount: str,
    description: str = "テスト経費",
) -> ExpenseRecord:
    return ExpenseRecord(
        transaction_id=transaction_id,
        spent_on=date(2026, 7, 1),
        description=description,
        category=category,
        amount=Decimal(amount),
        source_line=2,
    )


def test_expenses_are_summarized() -> None:
    """
    要件:
    次の3件を作成する。
    TX-001:
    travel 14850円
    TX-002:
    food 1200円
    TX-003:
    travel 3400円
    summarize_expenses()を実行する。
    transaction_count:
    3
    total_amount:
    Decimal("19450")
    travel合計:
    Decimal("18250")
    food合計:
    Decimal("1200")
    largest_expense.transaction_id:
    "TX-001"
    """
    # 1. 要件に従って 3 件の経費レコードを作成する
    r1 = create_record(
        transaction_id="TX-001",
        category=ExpenseCategory.TRAVEL,
        amount="14850",
    )
    r2 = create_record(
        transaction_id="TX-002",
        category=ExpenseCategory.FOOD,
        amount="1200",
    )
    r3 = create_record(
        transaction_id="TX-003",
        category=ExpenseCategory.TRAVEL,
        amount="3400",
    )
    # 2. 集計処理を実行する
    summary = summarize_expenses([r1, r2, r3])
    # 3. 結果の検証 (assert)
    assert summary.transaction_count == 3
    assert summary.total_amount == Decimal("19450")
    # カテゴリ別の合計の検証
    assert summary.totals_by_category[ExpenseCategory.TRAVEL] == Decimal("18250")
    assert summary.totals_by_category[ExpenseCategory.FOOD] == Decimal("1200")
    # 最高額経費の検証
    assert summary.largest_expense is not None
    assert summary.largest_expense.transaction_id == "TX-001"

def test_empty_records_return_empty_summary() -> None:
    """
    要件:
    空のリストを渡す。
    transaction_count:
    0
    total_amount:
    Decimal("0")
    totals_by_category:
    {}
    largest_expense:
    None
    """
    # 1. None
    # 2. 集計処理を実行する
    summary = summarize_expenses([])
    # 3. 結果の検証 (assert)
    assert summary.transaction_count == 0
    assert summary.total_amount == Decimal("0")
    # カテゴリ別の合計の検証
    assert summary.totals_by_category == {}
    # 最高額経費の検証
    assert summary.largest_expense is None

def test_duplicate_transaction_id_is_rejected() -> None:
    """
    要件:
    transaction_idが両方とも
    "TX-001"の明細を2件作成する。
    summarize_expenses()を実行すると
    DuplicateTransactionErrorが発生する。
    例外メッセージ:
    "duplicate transaction_id: TX-001"
    """
    # 1. 要件に従って 経費レコードを作成する
    r1 = create_record(
        transaction_id="TX-001",
        category=ExpenseCategory.TRAVEL,
        amount="14850",
    )
    r2 = create_record(
        transaction_id="TX-001",
        category=ExpenseCategory.TRAVEL,
        amount="14850",
    )

    with pytest.raises(
            DuplicateTransactionError,
            match="duplicate transaction_id: TX-001",
    ):
        # 2. 集計処理を実行する
        summarize_expenses([r1, r2])

def test_generator_can_be_summarized() -> None:
    """
    要件:
    ExpenseRecordを返す
    ジェネレータ式を作る。
    summarize_expenses()へ渡す。
    リストではなくジェネレータでも
    正しく集計できることを確認する。
    transaction_count:
    2
    total_amount:
    Decimal("3000")
    """
    # 1. 2件の経費レコードを用意する
    r1 = create_record(
        transaction_id="TX-001",
        category=ExpenseCategory.TRAVEL,
        amount="1000",
    )
    r2 = create_record(
        transaction_id="TX-002",
        category=ExpenseCategory.FOOD,
        amount="2000",
    )
    # 2. 丸カッコ () を使ってジェネレータ式を作る
    records_generator = (r for r in [r1, r2])
    # 3. ジェネレータをそのまま summarize_expenses() へ渡す
    summary = summarize_expenses(records_generator)
    # 4. 集計結果の検証
    assert summary.transaction_count == 2
    assert summary.total_amount == Decimal("3000")
