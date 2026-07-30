const stock_guard = @import("stock_guard");
const reporter = @import("presentation/console_reporter.zig");

const StockItem = stock_guard.stock_item.StockItem;

const Priority = stock_guard.stock_item.Priority;

pub fn main() void {
    const items = [_]StockItem{
        .{
            .product_code = "ITEM-001",
            .current_stock = 8,
            .reorder_point = 5,
            .target_stock = 15,
            .priority = Priority.normal,
            .discontinued = false,
        },
        .{
            .product_code = "ITEM-002",
            .current_stock = 3,
            .reorder_point = 5,
            .target_stock = 12,
            .priority = Priority.normal,
            .discontinued = false,
        },
        .{
            .product_code = "ITEM-003",
            .current_stock = 0,
            .reorder_point = 4,
            .target_stock = 10,
            .priority = Priority.high,
            .discontinued = false,
        },
    };

    for (items) |item| {
        const decision = stock_guard
            .reorder_service
            .evaluateReorder(item);

        reporter.printDecision(decision);
    }
}
