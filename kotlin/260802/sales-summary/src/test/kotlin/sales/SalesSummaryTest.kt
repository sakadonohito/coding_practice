package sales

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull

class SalesSummaryTest {
    @Test
    fun `同じ商品コードの販売明細を集計する`() {
        /*
         * 要件:
         * 次の3明細を用意する。
         * P-001 ノート 200円 3個
         * P-002 ボールペン 120円 5個
         * P-001 ノート 200円 2個
         * summarizeSalesを実行する。
         * productsの件数が2であることを確認する。
         * 先頭の商品が次と等しいことを確認する。
         * ProductSales(
         *     productCode = "P-001",
         *     productName = "ノート",
         *     totalQuantity = 5,
         *     totalAmount = 1000,
         * )
         * 2番目の商品が次と等しいことを確認する。
         * ProductSales(
         *     productCode = "P-002",
         *     productName = "ボールペン",
         *     totalQuantity = 5,
         *     totalAmount = 600,
         * )
         */
        val lines =
            listOf(
                SaleLine(
                    productCode = "P-001",
                    productName = "ノート",
                    unitPrice = 200,
                    quantity = 3,
                ),
                SaleLine(
                    productCode = "P-002",
                    productName = "ボールペン",
                    unitPrice = 120,
                    quantity = 5,
                ),
                SaleLine(
                    productCode = "P-001",
                    productName = "ノート",
                    unitPrice = 200,
                    quantity = 2,
                ),
            )
        val actual = summarizeSales(lines)
        assertEquals(2, actual.products.size)
        assertEquals(
            ProductSales(
                productCode = "P-001",
                productName = "ノート",
                totalAmount = 1000,
                totalQuantity = 5,
            ),
            actual.products[0],
        )
        assertEquals(
            ProductSales(
                productCode = "P-002",
                productName = "ボールペン",
                totalQuantity = 5,
                totalAmount = 600,
            ),
            actual.products[1],
        )
    }

    @Test
    fun `全体売上と最大売上商品を返す`() {
        /*
         * 要件:
         * 次の明細を用意する。
         * P-001 ノート 200円 3個
         * P-002 ファイル 350円 4個
         * summarizeSalesを実行する。
         * grandTotalが2000であることを確認する。
         * topProductが次と等しいことを確認する。
         * ProductSales(
         *     productCode = "P-002",
         *     productName = "ファイル",
         *     totalQuantity = 4,
         *     totalAmount = 1400,
         * )
         */
        val lines =
            listOf(
                SaleLine(
                    productCode = "P-001",
                    productName = "ノート",
                    unitPrice = 200,
                    quantity = 3,
                ),
                SaleLine(
                    productCode = "P-002",
                    productName = "ファイル",
                    unitPrice = 350,
                    quantity = 4,
                ),
            )
        val actual = summarizeSales(lines)
        assertEquals(2000, actual.grandTotal)
        assertEquals(
            ProductSales(
                productCode = "P-002",
                productName = "ファイル",
                totalQuantity = 4,
                totalAmount = 1400,
            ),
            actual.topProduct,
        )
    }

    @Test
    fun `空の明細なら空の集計を返す`() {
        /*
         * 要件:
         * 空のListをsummarizeSalesへ渡す。
         * productsが空であることを確認する。
         * grandTotalが0であることを確認する。
         * topProductがnullであることをassertNullで確認する。
         */
        val lines = emptyList<SaleLine>()
        val actual = summarizeSales(lines)
        assertEquals(0, actual.products.size)
        assertEquals(0, actual.grandTotal)
        assertNull(actual.topProduct)
    }

    @Test
    fun `販売個数が0なら例外になる`() {
        /*
         * 要件:
         * quantityが0のSaleLineを作ろうとする。
         * IllegalArgumentExceptionが発生することを
         * assertFailsWithで確認する。
         * 例外メッセージが次と等しいことを確認する。
         * "quantity must be at least 1: 0"
         */
        val exception =
            assertFailsWith<IllegalArgumentException> {
                val lines =
                    listOf(
                        SaleLine(
                            productCode = "P-001",
                            productName = "ノート",
                            unitPrice = 200,
                            quantity = 0,
                        ),
                    )
            }
        assertEquals(
            "quantity must be at least 1: 0",
            exception.message,
        )
    }
}
