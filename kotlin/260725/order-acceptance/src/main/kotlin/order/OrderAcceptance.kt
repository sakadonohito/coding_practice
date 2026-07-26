package order

enum class CustomerType {
    REGULAR,
    PRIORITY,
}

data class OrderRequest(
    val productCode: String,
    val quantity: Int,
    val stock: Int,
    val customerType: CustomerType,
    val reservationNumber: String? = null,
)

sealed interface OrderDecision {
    data class Accepted(
        val allocatedQuantity: Int,
    ) : OrderDecision

    data class PriorityReservationAccepted(
        val reservationNumber: String,
        val allocatedQuantity: Int,
    ) : OrderDecision

    data class RejectedForInsufficientStock(
        val shortageQuantity: Int,
    ) : OrderDecision
}

fun evaluateOrder(
    request: OrderRequest,
): OrderDecision {
    validateOrder(request)

    if (request.stock >= request.quantity) {
        return OrderDecision.Accepted(
            allocatedQuantity = request.quantity,
        )
    }

    if (
        request.customerType == CustomerType.PRIORITY &&
        request.reservationNumber != null
    ) {
        return OrderDecision.PriorityReservationAccepted(
            reservationNumber = request.reservationNumber,
            allocatedQuantity = request.quantity,
        )
    }

    return OrderDecision.RejectedForInsufficientStock(
        shortageQuantity = request.quantity - request.stock,
    )
}

private fun validateOrder(
    request: OrderRequest,
) {
    require(request.productCode.isNotBlank()) {
        "productCode must not be blank"
    }

    require(request.quantity >= 1) {
        "quantity must be at least 1: ${request.quantity}"
    }

    require(request.stock >= 0) {
        "stock must not be at negative: ${request.stock}"
    }

    require(
        request.customerType == CustomerType.PRIORITY ||
        request.reservationNumber == null,
    ) {
        "regular customers cannot specify a reservation number"
    }
}
