from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from enum import StrEnum

type TransactionId = str

class ExpenseCategory(StrEnum):
    FOOD = "food"
    TRAVEL = "travel"
    SUPPLIES = "supplies"
    OTHER = "other"

@dataclass(frozen=True, slots=True, kw_only=True)
class ExpenseRecord:
    transaction_id: TransactionId
    spent_on: date
    description: str
    category: ExpenseCategory
    amount: Decimal
    source_line: int

@dataclass(frozen=True, slots=True, kw_only=True)
class ExpenseSummary:
    transaction_count: int
    total_amount: Decimal
    totals_by_category: dict[ExpenseCategory, Decimal]
    largest_expense: ExpenseRecord | None
