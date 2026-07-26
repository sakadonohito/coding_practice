// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

struct ShippingAddress: Equatable {
    let postalCode: String
    let addressLine: String
}

enum AddressValidationError: Error, Equatable {
    case emptyPostalCode
    case invalidPostalCode
    case emptyAddress
}

func makeShippingAddress(
  postalCode: String,
  addressLine: String
) -> Result<ShippingAddress, AddressValidationError> {
    let normalizedPostalCode = postalCode
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "-", with: "")

    let normalizedAddress = addressLine
      .trimmingCharacters(in: .whitespacesAndNewlines)

    if normalizedPostalCode.isEmpty {
        return .failure(.emptyPostalCode)
    }

    let isSevenDigits =
      normalizedPostalCode.count == 7 &&
      normalizedPostalCode.allSatisfy(\.isNumber)

    if !isSevenDigits {
        return .failure(.invalidPostalCode)
    }

    if normalizedAddress.isEmpty {
        return .failure(.emptyAddress)
    }

    let formattedPostalCode =
      normalizedPostalCode.prefix(3)
      + "-"
      + normalizedPostalCode.suffix(4)

    return .success(
      ShippingAddress(
        postalCode: String(formattedPostalCode),
        addressLine: normalizedAddress
      )
    )
}

@main
struct MakeShipping {
    static func main() {
        let result = makeShippingAddress(
          postalCode: " 123-4567 ",
          addressLine: " 東京都千代田区1-1 "
        )
        print(result)
    }
}
