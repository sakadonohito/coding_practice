// The Swift Programming Language
// https://docs.swift.org/swift-book

@main
struct ShoppingPurchase {
    static func main() {
        let items = [
          ShoppingItem(name: "牛乳", price: 200, purchased: true),
          ShoppingItem(name: "パン", price: 150, purchased: false),
          ShoppingItem(name: "卵", price: 300, purchased: true)
        ]
        let total = totalPurchasedAmount(items: items)
        print(total)
        //print(greeting())
    }
}

// テスト対象にするロジックを切り出す
func greeting() -> String {
    "Hello, world!"
}

struct ShoppingItem {
    let name: String
    let price: Int
    let purchased: Bool

    init(name: String, price: Int, purchased: Bool) {
        self.name = name
        self.price = price
        self.purchased = purchased
    }
}

func totalPurchasedAmount(items: [ShoppingItem]) -> Int {
    return items
      .filter { item in item.purchased }
      .map { item in item.price }
      .reduce(0) { total, price in total + price }
}
