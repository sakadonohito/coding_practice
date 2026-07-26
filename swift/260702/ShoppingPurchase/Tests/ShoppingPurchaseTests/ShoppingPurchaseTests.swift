import XCTest
@testable import ShoppingPurchase

final class ShoppingPurchaseTests: XCTestCase {
    func testTotalPurchasedAmountReturnsSumOfPurchasedItems() {
        // 1. 購入済みの商品と未購入の商品が混ざった配列を用意してください。
        // 2. 購入済み商品の price が 200, 300, 500 になるようにしてください。
        let items = [
          ShoppingItem(name: "牛乳", price: 200, purchased: true),
          ShoppingItem(name: "パン", price: 150, purchased: false),
          ShoppingItem(name: "卵", price: 300, purchased: true),
          ShoppingItem(name: "チーズ", price: 500, purchased: true)
        ]
        // 3. totalPurchasedAmount(items:) を呼び出してください。
        let got = totalPurchasedAmount(items: items)
        // 4. 結果が 1000 になることを検証してください。
        let want = 1000

        XCTAssertEqual(got, want, "購入済み商品の合計金額が期待値と一致すること")
    }

    func testTotalPurchasedAmountReturnsZeroWhenNoItemsPurchased() {
        // 1. すべて purchased = false の商品配列を用意してください。
        let items = [
          ShoppingItem(name: "牛乳", price: 200, purchased: false),
          ShoppingItem(name: "パン", price: 150, purchased: false),
          ShoppingItem(name: "卵", price: 300, purchased: false),
          ShoppingItem(name: "チーズ", price: 500, purchased: false)
        ]
        // 2. totalPurchasedAmount(items:) を呼び出してください。
        let got = totalPurchasedAmount(items: items)
        // 3. 結果が 0 になることを検証してください。
        let want = 0
        XCTAssertEqual(got, want, "購入済み商品の合計金額が0であること。")
    }

    func testTotalPurchasedAmountReturnsZeroWhenItemsIsEmpty() {
        // 1. 空の ShoppingItem 配列を用意してください。
        let items: [ShoppingItem] = []
        // 2. totalPurchasedAmount(items:) を呼び出してください。
        let got = totalPurchasedAmount(items: items)
        // 3. 結果が 0 になることを検証してください。
        let want = 0
        XCTAssertEqual(got, want, "購入済み商品が空の場合、合計金額が0になること。")
    }
}
