import XCTest
@testable import OrderStatusTransition

final class OrderStatusTransitionTests: XCTestCase {

    func testReceivedOrderCanChangeToCooking() throws {
        // 1. statusが.receivedのOrderを作成してください。
        var order = Order(
          id: 893,
          status: .received
        )
        // 2. changeStatus(to: .cooking)を呼び出してください。
        try order.changeStatus(to: .cooking)

        // 3. statusが.cookingになったことを確認してください。
        XCTAssertEqual(
          order.status,
          .cooking,
          "statusが.cookingになっていること"
        )
    }

    func testCookingOrderCanChangeToDelivering() throws {
        // 1. statusが.cookingのOrderを作成してください。
        var order = Order(
          id: 893,
          status: .cooking
        )
        // 2. changeStatus(to: .delivering)を呼び出してください。
        try order.changeStatus(to: .delivering)

        // 3. statusが.deliveringになったことを確認してください。
        XCTAssertEqual(
          order.status,
          .delivering,
          "statusが.deliveringになっていること"
        )
    }

    func testReceivedOrderCannotChangeDirectlyToDelivering() {
        // 1. statusが.receivedのOrderを作成してください。
        var order = Order(
          id: 893,
          status: .received
        )

        // 2. changeStatus(to: .delivering)を呼び出してください。
        // 3. OrderError.invalidTransitionが投げられることを確認してください。
        XCTAssertThrowsError(
          try order.changeStatus(to: .delivering)
        ) { error in
            switch error {
            case let OrderError.invalidTransition(from, to):
                XCTAssertEqual(from, .received)
                XCTAssertEqual(to, .delivering)

            default:
                XCTFail("想定していないエラーです")
            }
        }

        // 4. エラー発生後もstatusが.receivedのままであることを確認してください。
        XCTAssertEqual(
          order.status,
          .received,
          "statusが.receivedのままであること"
        )
    }

    func testCompletedOrderCannotReturnToCooking() {
        // 1. statusが.completedのOrderを作成してください。
        var order = Order(
          id: 893,
          status: .completed
        )

        // 2. changeStatus(to: .cooking)を呼び出してください。
        // 3. OrderError.invalidTransitionが投げられることを確認してください。
        XCTAssertThrowsError(
          try order.changeStatus(to: .cooking)
        ) { error in
            switch error {
            case let OrderError.invalidTransition(from, to):
                XCTAssertEqual(from, .completed)
                XCTAssertEqual(to, .cooking)

            default:
                XCTFail("想定していないエラーです")
            }
        }

        // 4. statusが.completedのままであることを確認してください。
        XCTAssertEqual(
          order.status,
          .completed,
          "statusが.completedのままであること"
        )
    }
}
