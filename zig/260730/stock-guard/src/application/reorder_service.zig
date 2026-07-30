const stock_item = @import("../domain/stock_item.zig");
const reorder_decision = @import("../domain/reorder_decision.zig");

const StockItem = stock_item.StockItem;
const Priority = stock_item.Priority;
const ReorderDecision = reorder_decision.ReorderDecision;

pub fn evaluateReorder(
    item: StockItem,
) ReorderDecision {
    item.validate() catch |validation_error| {
        return .{
            .rejected = .{
                .product_code = item.product_code,
                .reason = validationErrorMessage(
                    validation_error,
                ),
            },
        };
    };

    if (item.discontinued) {
        return .{
            .rejected = .{
                .product_code = item.product_code,
                .reason = "discontinued product",
            },
        };
    }

    if (item.current_stock > item.reorder_point) {
        return .{
            .no_reorder = .{
                .product_code = item.product_code,
                .current_stock = item.current_stock,
            },
        };
    }

    const order_quantity = item.target_stock - item.current_stock;

    if (item.current_stock == 0 or
        item.priority == Priority.high)
    {
        return .{
            .urgent_reorder = .{
                .product_code = item.product_code,
                .order_quantity = order_quantity,
                .reason = urgentReason(item),
            },
        };
    }

    return .{
        .standard_reorder = .{
            .product_code = item.product_code,
            .order_quantity = order_quantity,
        },
    };
}

fn urgentReason(item: StockItem) []const u8 {
    if (item.current_stock == 0) {
        return "out of stock";
    }

    return "high priority product";
}

fn validationErrorMessage(
    validation_error: stock_item.ValidationError,
) []const u8 {
    return switch (validation_error) {
        error.BlankProductCode => "product code must not be blank",

        error.ReorderPointExceedsTarget => "reorder point must not exceed target stock",

        error.CurrentStockExceedsTarget => "current stock must not exceed target stock",
    };
}
