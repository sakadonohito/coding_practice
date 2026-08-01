from collections import defaultdict
from collections.abc import Iterable
from decimal import Decimal

from expense_importer.errors import (
    DuplicateTransactionError,
)
from expense_importer.models import (
    ExpenseCategory,
    ExpenseRecord,
    ExpenseSummary,
)

def summarize_expenses(
        records: Iterable[ExpenseRecord],
) -> ExpenseSummary:
    materialized_records = tuple(records)

    _validate_unique_transaction_ids(
        materialized_records
    )

    totals_by_category: defaultdict[
        ExpenseCategory,
        Decimal,
    ] = defaultdict(lambda: Decimal("0"))

    total_amount = Decimal("0")

    for record in materialized_records:
        total_amount += record.amount
        totals_by_category[
            record.category
        ] += record.amount

    largest_expense = max(
        materialized_records,
        key=lambda record: record.amount,
        default=None,
    )

    return ExpenseSummary(
        transaction_count=len(
            materialized_records
        ),
        total_amount=total_amount,
        totals_by_category=dict(
            totals_by_category
        ),
        largest_expense=largest_expense,
    )

def _validate_unique_transaction_ids(
        records: Iterable[ExpenseRecord],
) -> None:
    seen_transaction_ids: set[str] = set()

    for record in records:
        if (
                record.transaction_id
                in seen_transaction_ids
        ):
            raise DuplicateTransactionError(
                record.transaction_id
            )

        seen_transaction_ids.add(
            record.transaction_id
        )
