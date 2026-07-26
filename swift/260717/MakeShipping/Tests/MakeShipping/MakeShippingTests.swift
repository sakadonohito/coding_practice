import XCTest
@testable import MakeShipping

//import XCTest
//@testable import ShippingAddress

final class ShippingAddressTests: XCTestCase {

    func testValidAddressIsNormalized() {
        // 郵便番号として" 123-4567 "を渡してください。
        // 住所として" 東京都千代田区1-1 "を渡してください。
        let result = makeShippingAddress(
          postalCode: " 123-4567 ",
          addressLine: " 東京都千代田区1-1 "
        )
        // 結果が、郵便番号と住所の前後空白を除去した
        // .success(ShippingAddress(...))になることを確認してください。
        XCTAssertEqual(
          result,
          .success(
            ShippingAddress(
              postalCode: "123-4567",
              addressLine: "東京都千代田区1-1"
            )
          )
        )
    }

    func testPostalCodeWithoutHyphenIsFormatted() {
        // 郵便番号として"1234567"を渡してください。
        let result = makeShippingAddress(
          postalCode: " 1234567 ",
          addressLine: " 東京都千代田区1-1 "
        )
        // 結果の郵便番号が"123-4567"になることを確認してください。
        XCTAssertEqual(
          result,
          .success(
            ShippingAddress(
              postalCode: "123-4567",
              addressLine: "東京都千代田区1-1"
            )
          )
        )
    }

    func testEmptyPostalCodeReturnsFailure() {
        // 郵便番号として空白だけの文字列を渡してください。
        let result = makeShippingAddress(
          postalCode: "",
          addressLine: " 東京都千代田区1-1 "
        )
        // 結果が.failure(.emptyPostalCode)になることを確認してください。
        XCTAssertEqual(
          result,
          .failure(.emptyPostalCode)
        )
    }

    func testShortPostalCodeReturnsFailure() {
        // 郵便番号として"123456"を渡してください。
        let result = makeShippingAddress(
          postalCode: "123456",
          addressLine: " 東京都千代田区1-1 "
        )
        // 結果が.failure(.invalidPostalCode)になることを確認してください。
        XCTAssertEqual(
          result,
          .failure(.invalidPostalCode)
        )
    }

    func testPostalCodeContainingLettersReturnsFailure() {
        // 郵便番号として"123A567"を渡してください。
        let result = makeShippingAddress(
          postalCode: "123A567",
          addressLine: " 東京都千代田区1-1 "
        )
        // 結果が.failure(.invalidPostalCode)になることを確認してください。
        XCTAssertEqual(
          result,
          .failure(.invalidPostalCode)
        )
    }

    func testEmptyAddressReturnsFailure() {
        // 正しい郵便番号と、空白だけの住所を渡してください。
        let result = makeShippingAddress(
          postalCode: "123-4567",
          addressLine: " 　"
        )
        // 結果が.failure(.emptyAddress)になることを確認してください。
        XCTAssertEqual(
          result,
          .failure(.emptyAddress)
        )
    }
}
