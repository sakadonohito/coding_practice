package sales

fun main() {
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
                productCode = "P-003",
                productName = "ノート",
                unitPrice = 200,
                quantity = 2,
            ),
        )

    val report = summarizeSales(lines)

    report.products.forEach { product ->
        println(
            "${product.productName}: " +
                "${product.totalQuantity}個 " +
                "${product.totalAmount}円",
        )
    }

    println("全体売上: ${report.grandTotal}円")
    println(
        "最大売上商品: " +
            (report.topProduct?.productName ?: "なし"),
    )
}
