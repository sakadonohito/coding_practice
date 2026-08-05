package sales

data class SaleLine(
    val productCode: String,
    val productName: String,
    val unitPrice: Int,
    val quantity: Int,
) {
    init {
        require(productCode.isNotBlank()) {
            "productCode must not be blank"
        }
        require(productName.isNotBlank()) {
            "productName must not be blank"
        }
        require(unitPrice >= 1) {
            "unitPrice must be at least 1: $unitPrice"
        }
        require(quantity >= 1) {
            "quantity must be at least 1: $quantity"
        }
    }

    val lineTotal: Int
        get() = unitPrice * quantity
}

data class ProductSales(
    val productCode: String,
    val productName: String,
    val totalQuantity: Int,
    val totalAmount: Int,
)

data class SalesReport(
    val products: List<ProductSales>,
    val grandTotal: Int,
    val topProduct: ProductSales?,
)

fun summarizeSales(lines: List<SaleLine>): SalesReport {
    val products =
        lines
            .groupBy { line -> line.productCode }
            .map { (productCode, productLines) ->
                val firstLine = productLines.first()

                ProductSales(
                    productCode = productCode,
                    productName = firstLine.productName,
                    totalQuantity =
                        productLines.sumOf { line ->
                            line.quantity
                        },
                    totalAmount =
                        productLines.sumOf { line ->
                            line.lineTotal
                        },
                )
            }

    return SalesReport(
        products = products,
        grandTotal =
            lines.sumOf { line ->
                line.lineTotal
            },
        topProduct =
            products.maxByOrNull { product ->
                product.totalAmount
            },
    )
}
