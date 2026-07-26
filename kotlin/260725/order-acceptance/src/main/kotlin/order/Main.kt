package order

fun main() {
    val request = OrderRequest(
        productCode = "ITEM-001",
        quantity = 5,
        stock = 2,
        customerType = CustomerType.REGULAR,
    )

    val decision = evaluateOrder(request)

    when (decision) {
        is OrderDecision.Accepted -> {
            println("注文を受け付けました")
            println("引当数量: ${decision.allocatedQuantity}")
        }

        is OrderDecision.PriorityReservationAccepted -> {
            println("優先取り置きとして受け付けました")
            println("予約番号: ${decision.reservationNumber}")
            println("引当数量: ${decision.allocatedQuantity}")
        }

        is OrderDecision.RejectedForInsufficientStock -> {
            println("在庫不足により受け付けられません")
            println("不足数量: ${decision.shortageQuantity}")
        }
    }
}
