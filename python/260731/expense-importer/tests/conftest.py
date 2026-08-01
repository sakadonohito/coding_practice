from pathlib import Path

import pytest


@pytest.fixture
def valid_csv_path(
    tmp_path: Path,
) -> Path:
    csv_path = tmp_path / "expenses.csv"

    csv_path.write_text(
        (
            "transaction_id,spent_on,"
            "description,category,amount\n"
            "TX-001,2026-07-01,"
            "新幹線代,travel,14850\n"
            "TX-002,2026-07-02,"
            "昼食,food,1200\n"
            "TX-003,2026-07-03,"
            "プリンター用紙,supplies,980\n"
        ),
        encoding="utf-8",
    )

    return csv_path
