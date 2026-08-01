from datetime import date
from decimal import Decimal
from pathlib import Path

import pytest

from expense_importer.errors import (
    InvalidCsvHeaderError,
    RowValidationError,
)
from expense_importer.models import (
    ExpenseCategory,
)
from expense_importer.parser import (
    parse_expense_csv,
)

# 補助関数用の追加
import csv
from collections.abc import Mapping, Sequence
from pathlib import Path

CSV_COLUMNS = (
    "transaction_id",
    "spent_on",
    "description",
    "category",
    "amount",
)

def write_csv(
    path: Path,
    rows: Sequence[Mapping[str, str]],
    *,
    fieldnames: Sequence[str] = CSV_COLUMNS,
) -> Path:
    with path.open(
        mode="w",
        encoding="utf-8",
        newline="",
    ) as csv_file:
        writer = csv.DictWriter(
            csv_file,
            fieldnames=fieldnames,
        )

        writer.writeheader()
        writer.writerows(rows)

    return path

def valid_row() -> dict[str, str]:
    return {
        "transaction_id": "TX-001",
        "spent_on": "2026-07-01",
        "description": "テスト経費",
        "category": "travel",
        "amount": "1000",
    }
# 補助関数用の追加ここまで

def test_valid_csv_is_parsed(
    valid_csv_path: Path,
) -> None:
    """
    要件:
    valid_csv_pathを
    parse_expense_csv()へ渡す。
    3件読み込まれることを確認する。
    最初の明細について次を確認する。
    transaction_id:
    "TX-001"
    spent_on:
    date(2026, 7, 1)
    description:
    "新幹線代"
    category:
    ExpenseCategory.TRAVEL
    amount:
    Decimal("14850")
    source_line:
    2
    """

    # 1. parse_expense_csv() に Path を渡し、結果をリスト化する
    records = parse_expense_csv(valid_csv_path)
    # 2. 件数が 3 件であることを確認する
    assert len(records) == 3
    # 3. 最初の明細 (records[0]) の各フィールドを検証する
    first_record = records[0]
    assert first_record.transaction_id == "TX-001"
    assert first_record.spent_on == date(2026, 7, 1)
    assert first_record.description == "新幹線代"
    assert first_record.category == ExpenseCategory.TRAVEL
    assert first_record.amount == Decimal("14850")
    assert first_record.source_line == 2

def test_missing_header_is_rejected(
    tmp_path: Path,
) -> None:
    """
    要件:
    amount列がないCSVを作成する。
    parse_expense_csv()を実行すると
    InvalidCsvHeaderErrorが発生する。
    例外メッセージ:
    "missing CSV columns: amount"
    """
    # 1. tmp_path の中にテスト用 CSV ファイルのパスを作る
    csv_file = tmp_path / "invalid_header.csv"
    # 2. amount 列が含まれないヘッダー（とダミーデータ）を書き込む
    csv_file.write_text(
        "transaction_id,spent_on,description,category\n"
        "TX-001,2026-07-01,新幹線代,travel\n",
        encoding="utf-8",
    )

    with pytest.raises(
            InvalidCsvHeaderError,
            match="missing CSV columns: amount"
    ):
        parse_expense_csv(csv_file)


@pytest.mark.parametrize(
    (
        "field_name",
        "field_value",
        "expected_message",
    ),
    [
        (
            "spent_on",
            "2026/07/01",
            "must use YYYY-MM-DD format",
        ),
        (
            "category",
            "entertainment",
            (
                "unsupported category: "
                "entertainment"
            ),
        ),
        (
            "amount",
            "abc",
            "must be a decimal number",
        ),
        (
            "amount",
            "0",
            "must be greater than zero",
        ),
    ],
)
def test_invalid_field_is_rejected(
    tmp_path: Path,
    field_name: str,
    field_value: str,
    expected_message: str,
) -> None:
    """
    要件:
    正常な1行分の辞書を用意する。
    field_nameに対応する値を
    field_valueへ差し替える。
    CSVファイルを作る。
    parse_expense_csv()を実行すると
    ExceptionGroupが発生する。
    ExceptionGroup内の最初の例外が
    RowValidationErrorであることを確認する。
    エラーのfield_nameが
    引数のfield_nameと一致する。
    エラーメッセージに
    expected_messageが含まれる。
    """
    # 1. 正常な 1 行分のデータ辞書を用意する
    row = valid_row()

    # 2. テスト対象のフィールドの値を不正な値 (field_value) に差し替える
    row[field_name] = field_value
    # 3. CSV ファイルを作成して書き込む
    csv_path = write_csv(
        tmp_path / "invalid_field.csv",
        [row],
    )
    # 4. ExceptionGroup の発生を検証する
    with pytest.raises(
            ExceptionGroup,
            match="invalid expense rows",
    ) as group_info:
        parse_expense_csv(csv_path)

    assert len(group_info.value.exceptions) == 1
    error = group_info.value.exceptions[0]

    assert isinstance(error, RowValidationError)
    assert error.line_number == 2
    assert error.field_name == field_name
    assert expected_message in str(error)

def test_multiple_invalid_rows_are_grouped(
    tmp_path: Path,
) -> None:
    """
    要件:
    次の2つの不正行を含むCSVを作成する。
    2行目:
    spent_on = "invalid-date"
    3行目:
    amount = "-100"
    parse_expense_csv()を実行すると
    ExceptionGroupが発生する。
    group.value.exceptionsの件数が
    2件であることを確認する。
    各例外のline_numberが
    [2, 3]であることを確認する。
    """
    # 1. 2つの不正行を含む CSV ファイルを作成する
    first_row = valid_row()
    first_row["spent_on"] = "invalid-date"

    second_row = valid_row()
    second_row["transaction_id"] = "TX-002"
    second_row["amount"] = "-100"

    csv_path = write_csv(
        tmp_path / "multiple_invalid.csv",
        [first_row, second_row],
    )

    with pytest.raises(
            ExceptionGroup,
            match="invalid expense rows",
    ) as group_info:
        parse_expense_csv(csv_path)

    errors = group_info.value.exceptions

    assert len(errors) == 2
    assert all(
        isinstance(error, RowValidationError)
        for error in errors
    )

    assert [
        error.line_number
        for error in errors
    ] == [2,3]

    assert [
        error.field_name
        for error in errors
    ] == [
        "spent_on",
        "amount",
    ]
