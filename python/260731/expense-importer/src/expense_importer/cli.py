import argparse
from pathlib import Path

from expense_importer.errors import (
    ExpenseImportError,
    RowValidationError,
)
from expense_importer.parser import (
    parse_expense_csv,
)
from expense_importer.service import (
    summarize_expenses,
)

def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "経費CSVを読み込み、集計します"
        )
    )

    parser.add_argument(
        "csv_path",
        type=Path,
        help="読み込むCSVファイル",
    )

    args = parser.parse_args()

    try:
        records = parse_expense_csv(
            args.csv_path
        )

        summary = summarize_expenses(records)

    except* RowValidationError as group:
        print("CSVの行に問題があります。")

        for error in group.exceptions:
            printf(f"- {error}")

        raise SystemExit(1)

    except* ExpenseImportError as group:
        for error in group.exceptions:
            printf(f"- {error}")

        raise SystemExit(1)

    print(
        f"取引件数: "
        f"{summary.transaction_count}"
    )
    print(
        f"合計金額: "
        f"{summary.total_amount}円"
    )

    for category, amount in (
            summary.totals_by_category.items()
    ):
        print(
            f"合計金額: "
            f"{summary.total_amount}円"
        )

    if summary.largest_expense is not None:
        print(
            "最大経費: "
            f"{summary.largest_expense.description} "
            f"{summary.largest_expense.amount}円"
        )
