const std = @import("std");
const stock_guard = @import("stock_guard");

const ReorderDecision = stock_guard.reorder_decision.ReorderDecision;

pub fn printDecision(
    decision: ReorderDecision,
) void {
    switch (decision) {
        .no_reorder => |result| {
            std.debug.print(
                "{s}: 補充不要（現在庫 {d}）\n",
                .{
                    result.product_code,
                    result.current_stock,
                },
            );
        },

        .standard_reorder => |result| {
            std.debug.print(
                "{s}: 通常補充 {d}個\n",
                .{
                    result.product_code,
                    result.order_quantity,
                },
            );
        },

        .urgent_reorder => |result| {
            std.debug.print(
                "{s}: 緊急補充 {d}個 ({s}) \n",
                .{
                    result.product_code,
                    result.order_quantity,
                    result.reason,
                },
            );
        },

        .rejected => |result| {
            std.debug.print(
                "{s}: 入力拒否 ({s}) \n",
                .{
                    result.product_code,
                    result.reason,
                },
            );
        },
    }
}
