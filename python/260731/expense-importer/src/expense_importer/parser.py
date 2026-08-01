import csv
from collections.abc import Iterator
from datetime import date
from decimal import Decimal, InvalidOperation
from pathlib import Path

from expense_importer.errors import (
    InvalidCsvHeaderError,
    RowValidationError,
)

from expense_importer.models import (
    ExpenseCategory,
    ExpenseRecord,
)

REQUIRED_COLUMNS = frozenset(
    {
        "transaction_id",
        "spent_on",
        "description",
        "category",
        "amount",
    }
)

def parse_expense_csv(
        path: Path,
) -> list[ExpenseRecord]:
    errors: list[RowValidationError] = []
    records: list[ExpenseRecord] = []

    with path.open(
            mode="r",
            encoding="utf-8-sig",
            newline="",
    ) as csv_file:
        reader = csv.DictReader(csv_file)

        _validate_header(reader.fieldnames)

        for line_number, row in enumerate(
                reader,
                start=2,
        ):
            try:
                records.append(
                    _parse_row(
                        row,
                        line_number=line_number,
                    )
                )
            except RowValidationError as error:
                errors.append(error)

    if errors:
        raise ExceptionGroup(
            "invalid expense rows",
            errors,
        )

    return records

def iter_expense_csv(
        path: Path,
) -> Iterator[ExpenseRecord]:
    """
    正常なCSVを1行ずつExpenseRecordとして返す。

    この関数は複数行を一度にリストへ格納せず、
    yieldによって1件ずつ返す。
    """
    with path.open(
            mode="r",
            encoding="utf-8-sig",
            newline="",
    ) as csv_file:
        reader = csv.DictReader(csv_file)

        _validate_header(reader.fieldnames)

        for line_number, row in enumerate(
                reader,
                start=2,
        ):
            yield _parse_row(
                row,
                line_number=line_number,
            )

def _validate_header(
        fieldnames: list[str] | None,
) -> None:
    if fieldnames is None:
        raise InvalidCsvHeaderError(
            "CSV header is missing"
        )

    missing_columns = (
        REQUIRED_COLUMNS - set(fieldnames)
    )

    if missing_columns:
        missing_text = ", ".join(
            sorted(missing_columns)
        )

        raise InvalidCsvHeaderError(
            f"missing CSV columns: {missing_text}"
        )

def _parse_row(
        row: dict[str, str | None],
        *,
        line_number: int,
) -> ExpenseRecord:
    transaction_id = _required_text(
        row,
        field_name="transaction_id",
        line_number=line_number,
    )

    description = _required_text(
        row,
        field_name="description",
        line_number=line_number,
    )

    spent_on_text = _required_text(
        row,
        field_name="spent_on",
        line_number=line_number,
    )

    category_text = _required_text(
        row,
        field_name="category",
        line_number=line_number,
    )

    amount_text = _required_text(
        row,
        field_name="amount",
        line_number=line_number,
    )

    try:
        spent_on = date.fromisoformat(
            spent_on_text
        )
    except ValueError as error:
        raise RowValidationError(
            line_number=line_number,
            field_name="spent_on",
            message=(
                "must use YYYY-MM-DD format"
            ),
        ) from error

    try:
        category = ExpenseCategory(
            category_text.lower()
        )
    except ValueError as error:
        raise RowValidationError(
            line_number=line_number,
            field_name="category",
            message=(
                f"unsupported category: "
                f"{category_text}"
            ),
        ) from error

    try:
        amount = Decimal(amount_text)
    except InvalidOperation as error:
        raise RowValidationError(
            line_number=line_number,
            field_name="amount",
            message="must be a decimal number",
        ) from error

    if not amount.is_finite():
        raise RowValidationError(
            line_number=line_number,
            field_name="amount",
            message="must be finite",
        )

    if amount <= 0:
        raise RowValidationError(
            line_number=line_number,
            field_name="amount",
            message="must be greater than zero",
        )

    return ExpenseRecord(
        transaction_id=transaction_id,
        spent_on=spent_on,
        description=description,
        category=category,
        amount=amount,
        source_line=line_number,
    )

def _required_text(
        row: dict[str, str | None],
        *,
        field_name: str,
        line_number: int,
) -> str:
    value = row.get(field_name)

    if value is None or not value.strip():
        raise RowValidationError(
            line_number=line_number,
            field_name=field_name,
            message="must not be blank",
        )

    return value.strip()
