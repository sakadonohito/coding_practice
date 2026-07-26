package order

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource

class OrderAcceptanceTest {
    @Test
    fun `在庫が十分なら注文を受け付ける`() {
        /*
         * 要件:
         *
         * 商品コード: ITEM-001
         * 注文数量: 5
         * 現在庫: 8
         * 顧客区分: 一般顧客
         * 予約番号: なし
         *
         * evaluateOrderの結果が次と等しいことを確認する。
         *
         * OrderDecision.Accepted(
         *     allocatedQuantity = 5,
         * )
         */
        val request = OrderRequest(
            productCode = "ITEM-001",
            quantity = 5,
            stock = 8,
            customerType = CustomerType.REGULAR,
        )
        val actual = evaluateOrder(request)
        val expected = OrderDecision.Accepted(
            allocatedQuantity = 5,
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `在庫数と注文数量が同じでも受け付ける`() {
        /*
         * 要件:
         *
         * 商品コード: ITEM-002
         * 注文数量: 5
         * 現在庫: 5
         * 顧客区分: 一般顧客
         *
         * 結果がAcceptedになることを確認する。
         */
        val request = OrderRequest(
            productCode = "ITEM-002",
            quantity = 5,
            stock = 5,
            customerType = CustomerType.REGULAR,
        )
        val actual = evaluateOrder(request)
        val expected = OrderDecision.Accepted(
            allocatedQuantity = 5,
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `優先顧客は予約番号があれば在庫不足でも受け付ける`() {
        /*
         * 要件:
         *
         * 商品コード: ITEM-003
         * 注文数量: 5
         * 現在庫: 2
         * 顧客区分: 優先顧客
         * 予約番号: RSV-001
         *
         * 結果が次と等しいことを確認する。
         *
         * OrderDecision.PriorityReservationAccepted(
         *     reservationNumber = "RSV-001",
         *     allocatedQuantity = 5,
         * )
         */
        val request = OrderRequest(
            productCode = "ITEM-003",
            quantity = 5,
            stock = 2,
            customerType = CustomerType.PRIORITY,
            reservationNumber = "RSV-001",
        )
        val actual = evaluateOrder(request)
        val expected = OrderDecision.PriorityReservationAccepted(
            reservationNumber = "RSV-001",
            allocatedQuantity = 5,
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `通常顧客の在庫不足では不足数量を返す`() {
        /*
         * 要件:
         *
         * 商品コード: ITEM-004
         * 注文数量: 8
         * 現在庫: 3
         * 顧客区分: 一般顧客
         *
         * 不足数量は次の計算になる。
         *
         * 8 - 3 = 5
         *
         * 結果が次と等しいことを確認する。
         *
         * OrderDecision.RejectedForInsufficientStock(
         *     shortageQuantity = 5,
         * )
         */
        val request = OrderRequest(
            productCode = "ITEM-004",
            quantity = 8,
            stock = 3,
            customerType = CustomerType.REGULAR,
        )
        val actual = evaluateOrder(request)
        val expected = OrderDecision.RejectedForInsufficientStock(
            shortageQuantity = 5,
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `注文数量が0なら例外になる`() {
        /*
         * 要件:
         *
         * 注文数量に0を指定する。
         *
         * IllegalArgumentExceptionが発生することを確認する。
         *
         * 例外メッセージが次と等しいことも確認する。
         *
         * "quantity must be at least 1: 0"
         */
        val request = OrderRequest(
            productCode = "ITEM-001",
            quantity = 0,
            stock = 3,
            customerType = CustomerType.REGULAR,
        )
        val exception = assertFailsWith<IllegalArgumentException>{
            evaluateOrder(request)
        }
        assertEquals("quantity must be at least 1: 0", exception.message)
    }

    @Test
    fun `通常顧客が予約番号を指定すると例外になる`() {
        /*
         * 要件:
         *
         * 顧客区分: 一般顧客
         * 予約番号: RSV-999
         *
         * IllegalArgumentExceptionが発生することを確認する。
         *
         * 例外メッセージ:
         *
         * "regular customers cannot specify a reservation number"
         */
        val request = OrderRequest(
            productCode = "ITEM-001",
            quantity = 1,
            stock = 3,
            customerType = CustomerType.REGULAR,
            reservationNumber = "RSV-999",
        )
        val exception = assertFailsWith<IllegalArgumentException>{
            evaluateOrder(request)
        }
        assertEquals("regular customers cannot specify a reservation number", exception.message)
    }

    @DisplayName("複数の在庫不足ケースを検証する")
    @ParameterizedTest(name = "{0}")
    @MethodSource("insufficientStockCases")
    fun `在庫不足の不足数量を計算する`(
        caseName: String,
        quantity: Int,
        stock: Int,
        expectedShortage: Int,
    ) {
        /*
         * 要件:
         *
         * companion objectのinsufficientStockCasesから
         * テストデータを受け取る。
         *
         * 一般顧客の注文を作成する。
         *
         * evaluateOrderを実行する。
         *
         * 結果が次と等しいことを確認する。
         *
         * OrderDecision.RejectedForInsufficientStock(
         *     shortageQuantity = expectedShortage,
         * )
         *
         * caseNameはJUnitによってテスト名として使われる。
         */
        val request = OrderRequest(
            productCode = "ITEM-001",
            quantity = quantity,
            stock = stock,
            customerType = CustomerType.REGULAR,
        )

        val actual = evaluateOrder(request)
        val expected =
            OrderDecision.RejectedForInsufficientStock(
                shortageQuantity = expectedShortage,
            )
        assertEquals(expected, actual, "テストケース： $caseName")
    }

    companion object {
        @JvmStatic
        fun insufficientStockCases(): List<Array<Any>> =
            listOf(
                arrayOf(
                    "注文5・在庫2なら不足3",
                    5,
                    2,
                    3,
                ),
                arrayOf(
                    "注文10・在庫4なら不足6",
                    10,
                    4,
                    6,
                ),
                arrayOf(
                    "注文1・在庫0なら不足1",
                    1,
                    0,
                    1,
                ),
            )
    }
}
