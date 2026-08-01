class ExpenseImportError(Exception):
    """経費インポート処理の基底例外。"""

class InvalidCsvHeaderError(ExpenseImportError):
     """CSVヘッダーが不正な場合の例外。"""

class RowValidationError(ExpenseImportError):
    def __init__(
            self,
            *,
            line_number: int,
            field_name: str,
            message: str,
    ) -> None:
        self.line_number = line_number
        self.field_name = field_name

        super().__init__(
            f"line {line_number}, "
            f"field {field_name}: {message}"
        )

class DuplicateTransactionError(ExpenseImportError):
    def __init__(
            self,
            transaction_id: str,
    ) -> None:
        self.transaction_id = transaction_id

        super().__init__(
            f"duplicate transaction_id: {transaction_id}"
        )
