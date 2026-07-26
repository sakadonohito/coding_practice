import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class ShoppingItemJUnitTest {

    @Test
    fun `複数商品の合計金額を返す`() {
        // 1. 複数の ShoppingItem を持つリストを用意してください。
        val items = listOf(
            ShoppingItem("りんご", 120, 3),
            ShoppingItem("牛乳", 180, 2),
            ShoppingItem("パン", 150, 1)
        )
        // 2. calculateTotal を呼び出してください。
        val result = calculateTotal(items)
        // 3. price × quantity の合計金額と一致することを確認してください。
        val expected = (120 * 3) + (180 * 2) + (150 * 1)
        assertEquals(expected, result)
    }

    @Test
    fun `空のリストなら0を返す`() {
        // 1. 空の List<ShoppingItem> を用意してください。
        val items = emptyList<ShoppingItem>()
        // 2. calculateTotal を呼び出してください。
        val result = calculateTotal(items)
        // 3. 結果が 0 であることを確認してください。
        val expected = 0
        assertEquals(expected, result)
    }
}
