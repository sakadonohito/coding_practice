import Foundation

@main
struct CheckoutCalculatorApp {
    static func main() {
        let items = [
            CartItem(
                productCode: "P-001",
                name: "キーボード",
                unitPrice: 8_000,
                quantity: 2
            ),
            CartItem(
                productCode: "P-002",
                name: "マウス",
                unitPrice: 3_500,
                quantity: 1
            ),
        ]

        do {
            let summary = try calculateCheckout(
                items: items,
                coupon: .percentage(10),
                shippingFee: 600
            )

            print("商品小計: \(summary.itemSubtotal)円")
            print("割引額: \(summary.discountAmount)円")
            print("送料: \(summary.shippingFee)円")
            print("支払合計: \(summary.total)円")
        } catch {
            print("チェックアウトに失敗しました: \(error)")
        }
    }
}
