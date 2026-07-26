data class ShoppingItem(
    val name: String,
    val price: Int,
    val quantity: Int
)

fun calculateTotal(items: List<ShoppingItem>): Int {
    return items.sumOf { item ->
        item.price * item.quantity
    }
}

fun main() {
    val items = listOf(
        ShoppingItem("りんご", 120, 3),
        ShoppingItem("牛乳", 180, 2),
        ShoppingItem("パン", 150, 1)
    )

    val total = calculateTotal(items)

    println("合計金額： ${total}円")
}
