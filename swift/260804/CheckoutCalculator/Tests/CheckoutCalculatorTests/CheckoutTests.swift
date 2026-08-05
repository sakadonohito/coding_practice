import Testing

@testable import CheckoutCalculator

@Test("クーポンなしの合計を計算する")
func checkoutWithoutCoupon() throws {
    let items = [
      CartItem(
        productCode: "P-001", name: "item1", unitPrice: 8_000, quantity: 2
      ),
      CartItem(
        productCode: "P-002", name: "item2", unitPrice: 3_500, quantity: 1
      ),
    ]

    let actual = try calculateCheckout(
      items: items,
      shippingFee: 600
    )
    let expected = CheckoutSummary(
      itemSubtotal: 19_500, discountAmount: 0, shippingFee: 600, total: 20_100
    )

    #expect(actual == expected)
}

@Test(
  "割合割引を計算する",
  arguments: [
    (rate: 1, expected: 155),
    (rate: 10, expected: 1_550),
    (rate: 25, expected: 3_875),
    (rate: 100, expected: 15_500),
  ]
)
func percentageDiscount(
  rate: Int,
  expected: Int
) throws {
    let items = [
      CartItem(
        productCode: "P-001",
        name: "テスト商品",
        unitPrice: 15_500,
        quantity: 1
      )
    ]
    let actual = try calculateCheckout(
      items: items,
      coupon: .percentage(rate),
      shippingFee: 500
    )

    #expect(actual.discountAmount == expected)
}

@Test("固定割引は商品小計を超えない")
func fixedDiscountIsCappedAtSubtotal() throws {
    let items = [
      CartItem(
        productCode: "P-001",
        name: "テスト商品",
        unitPrice: 2_000,
        quantity: 1
      )
    ]
    let actual = try calculateCheckout(
      items: items,
      coupon: .fixedAmount(3_000),
      shippingFee: 500
    )

    #expect(actual.total == 500)
}

@Test("送料無料クーポンは送料だけを0にする")
func freeShippingCoupon() throws {
    let items = [
      CartItem(
        productCode: "P-001",
        name: "テスト商品",
        unitPrice: 4_000,
        quantity: 1
      )
    ]
    let actual = try calculateCheckout(
      items: items,
      coupon: .freeShipping,
      shippingFee: 700
    )

    #expect(actual.total == 4_000)
}

@Test("同じ商品コードがあればエラー")
func duplicateProductCodeThrows() {
    let items = [
      CartItem(
        productCode: "P-001",
        name: "テスト商品",
        unitPrice: 4_000,
        quantity: 1
      ),
      CartItem(
        productCode: "P-001",
        name: "テスト商品",
        unitPrice: 4_000,
        quantity: 2
      ),
    ]

    #expect(
      throws: CheckoutError.duplicateProductCode("P-001")
    ) {
        try calculateCheckout(
          items: items,
          shippingFee: 500
        )
    }
}

@Test(
  "不正な数量を拒否する",
  arguments: [0, -1]
)
func invalidQuantityThrows(
  quantity: Int
) {
    let items = [
      CartItem(
        productCode: "P-001",
        name: "テスト商品",
        unitPrice: 15_500,
        quantity: quantity
      )
    ]
    #expect(
      throws: CheckoutError.invalidQuantity(productCode: "P-001", value: quantity)
    ) {
        try calculateCheckout(
          items: items,
          shippingFee: 500
        )
    }
}
