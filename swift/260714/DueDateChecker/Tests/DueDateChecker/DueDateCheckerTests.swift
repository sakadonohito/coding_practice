import Foundation
import XCTest
@testable import DueDateChecker

final class DueDateCheckerTests: XCTestCase {

    private func makeDate(_ text: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(
            from: "\(text)T00:00:00Z"
        )!
    }

    func testFutureDateIsClassifiedAsUpcoming() {
        // 基準日を2026年7月14日にしてください。
        let referenceDate = makeDate("2026-07-14")
        // 期限日"2026-07-20"をcheckDueDateに渡してください。
        let result = checkDueDate(
          "2026-07-20",
          from: referenceDate
        )
        // 結果が.success(.upcoming(days: 6))であることを確認してください。
        XCTAssertEqual(
          result,
          .success(.upcoming(days: 6))
        )
    }

    func testSameDateIsClassifiedAsDueToday() {
        // 基準日を2026年7月14日にしてください。
        let referenceDate = makeDate("2026-07-14")
        // 期限日"2026-07-14"をcheckDueDateに渡してください。
        let result = checkDueDate(
          "2026-07-14",
          from: referenceDate
        )
        // 結果が.success(.dueToday)であることを確認してください。
        XCTAssertEqual(
          result,
          .success(.dueToday)
        )
    }

    func testPastDateIsClassifiedAsOverdue() {
        // 基準日を2026年7月14日にしてください。
        let referenceDate = makeDate("2026-07-14")
        // 期限日"2026-07-11"をcheckDueDateに渡してください。
        let result = checkDueDate(
          "2026-07-11",
          from: referenceDate
        )
        // 結果が.success(.overdue(days: 3))であることを確認してください。
        XCTAssertEqual(
          result,
          .success(.overdue(days: 3))
        )
    }

    func testInvalidDateTextReturnsFailure() {
        // 基準日を2026年7月14日にしてください。
        let referenceDate = makeDate("2026-07-14")
        // 不正な文字列"not-a-date"をcheckDueDateに渡してください。
        let result = checkDueDate(
          "not-a-date",
          from: referenceDate
        )
        // 結果が.failure(.invalidDateFormat)であることを確認してください。
        XCTAssertEqual(
          result,
          .failure(.invalidDateFormat)
        )
    }

    func testImpossibleDateReturnsFailure() {
        // 基準日を2026年7月14日にしてください。
        let referenceDate = makeDate("2026-07-14")
        // 存在しない日付"2026-07-42"をcheckDueDateに渡してください。
        let result = checkDueDate(
          "2026-07-42",
          from: referenceDate
        )
        // 結果が.failure(.invalidDateFormat)であることを確認してください。
        XCTAssertEqual(
          result,
          .failure(.invalidDateFormat)
        )
    }
}
