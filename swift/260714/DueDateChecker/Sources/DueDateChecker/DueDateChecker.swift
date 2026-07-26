// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

enum DueStatus: Equatable {
    case overdue(days: Int)
    case dueToday
    case upcoming(days: Int)
}

enum DueDateError: Error, Equatable {
    case invalidDateFormat
}

func checkDueDate(
  _ dueDateText: String,
  from referenceDate: Date
) -> Result<DueStatus, DueDateError> {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.isLenient = false

    guard let dueDate = formatter.date(from: dueDateText) else {
        return .failure(.invalidDateFormat)
    }

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let startOfReferenceDate = calendar.startOfDay(for: referenceDate)
    let startOfDueDate = calendar.startOfDay(for: dueDate)

    guard let difference = calendar.dateComponents(
            [.day],
            from: startOfReferenceDate,
            to: startOfDueDate
          ).day else {
        return .failure(.invalidDateFormat)
    }

    if difference < 0 {
        return .success(.overdue(days: abs(difference)))
    }

    if difference == 0 {
        return .success(.dueToday)
    }

    return .success(.upcoming(days: difference))
}

@main
struct DueDateChecker {
    static func main() {
        print("Hello, world!")
    }
}
