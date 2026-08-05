import Foundation

struct CartItem: Equatable, Sendable {
    let productCode: String
    let name: String
    let unitPrice: Int
    let quantity: Int

    var subtotal: Int {
        unitPrice * quantity
    }
}

enum Coupon: Equatable, Sendable {
    case none
    case percentage(Int)
    case fixedAmount(Int)
    case freeShipping
}

struct CheckoutSummary: Equatable, Sendable {
    let itemSubtotal: Int
    let discountAmount: Int
    let shippingFee: Int
    let total: Int
}

enum CheckoutError: Error, Equatable {
    case emptyCart
    case blankProductCode(index: Int)
    case blankProductName(productCode: String)
    case invalidUnitPrice(
           productCode: String,
           value: Int
         )
    case invalidQuantity(
           productCode: String,
           value: Int
         )
    case duplicateProductCode(String)
    case invalidShippingFee(Int)
    case invalidPercentage(Int)
    case invalidFixedAmount(Int)
}

func validateCart(
  _ items: [CartItem]
) throws {
    guard !items.isEmpty else {
        throw CheckoutError.emptyCart
    }
    var seenCodes = Set<String>()
    for (index, item) in items.enumerated() {
        if item.productCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CheckoutError.blankProductCode(index: index)
        }
        if item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CheckoutError.blankProductName(productCode: item.productCode)
        }
        if item.unitPrice < 1 {
            throw CheckoutError.invalidUnitPrice(productCode: item.productCode, value: item.unitPrice)
        }
        if item.quantity < 1 {
            throw CheckoutError.invalidQuantity(productCode: item.productCode, value: item.quantity)
        }
        let result = seenCodes.insert(item.productCode)
        if !result.inserted {
            throw CheckoutError.duplicateProductCode(item.productCode)
        }
    }
}

func calculateDiscount(
  itemSubtotal: Int,
  coupon: Coupon
) throws -> Int {
    switch coupon {
    case .none, .freeShipping:
        return 0
    case .percentage(let rate):
        guard (1...100).contains(rate) else {
            throw CheckoutError.invalidPercentage(rate)
        }
        return itemSubtotal * rate / 100
    case .fixedAmount(let amount):
        guard amount > 0 else {
            throw CheckoutError.invalidFixedAmount(amount)
        }
        return min(itemSubtotal, amount)
    }
}

func calculateCheckout(
  items: [CartItem],
  coupon: Coupon = .none,
  shippingFee: Int
) throws -> CheckoutSummary {
    try validateCart(items)
    guard shippingFee >= 0 else {
        throw CheckoutError.invalidShippingFee(shippingFee)
    }
    let itemSubtotal = items.reduce(into: 0){
        partialResult,
        item in
        partialResult += item.subtotal
    }
    let discount = try calculateDiscount(itemSubtotal: itemSubtotal, coupon: coupon)
    let appliedShippingFee = (coupon == .freeShipping) ? 0 : shippingFee
    let total = itemSubtotal - discount + appliedShippingFee
    return CheckoutSummary (
      itemSubtotal: itemSubtotal,
      discountAmount: discount,
      shippingFee: appliedShippingFee,
      total: total
    )
}
