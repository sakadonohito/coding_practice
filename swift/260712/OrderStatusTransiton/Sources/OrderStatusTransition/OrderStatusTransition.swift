// The Swift Programming Language
// https://docs.swift.org/swift-book

@main
struct OrderstatusTransition {
    static func main() {
        var order = Order(
          id: 101,
          status: .received
        )

        do {
            try order.changeStatus(to: .cooking)
            print("現在の状態: \(order.status.rawValue)")
            print("Debug: \(order.status)")

            try order.changeStatus(to: .delivering)
            print("現在の状態: \(order.status.rawValue)")
        } catch let OrderError.invalidTransition(from, to) {
            print(
              "\(from.rawValue) から \(to.rawValue) には変更できません"
            )
        } catch {
            print("予期しないエラーが発生しました")
        }
    }
}


enum OrderStatus: String {
    case received = "受付済み"
    case cooking = "調理中"
    case delivering = "配送中"
    case completed = "配達完了"
}

enum OrderError: Error {
    case invalidTransition(from: OrderStatus, to: OrderStatus)
}

struct Order {
    let id: Int
    private(set) var status: OrderStatus

    mutating func changeStatus(to newStatus: OrderStatus) throws {
        let isValid: Bool

        switch (status, newStatus) {
        case (.received, .cooking):
            isValid = true

        case (.cooking, .delivering):
            isValid = true

        case (.delivering, .completed):
            isValid = true

        default:
            isValid = false

        }

        guard isValid else {
            throw OrderError.invalidTransition(
              from: status,
              to: newStatus
            )
        }

        status = newStatus
    }
}
