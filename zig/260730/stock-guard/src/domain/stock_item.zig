const std = @import("std");

pub const Priority = enum {
    normal,
    high,
};

pub const StockItem = struct {
    product_code: []const u8,
    current_stock: u32,
    reorder_point: u32,
    target_stock: u32,
    priority: Priority,
    discontinued: bool,

    pub fn validate(self: StockItem) ValidationError!void {
        if (std.mem.trim(
            u8,
            self.product_code,
            " \t\r\n",
        ).len == 0) {
            return error.BlankProductCode;
        }

        if (self.reorder_point > self.target_stock) {
            return error.ReorderPointExceedsTarget;
        }

        if (self.current_stock > self.target_stock) {
            return error.CurrentStockExceedsTarget;
        }
    }
};

pub const ValidationError = error{
    BlankProductCode,
    ReorderPointExceedsTarget,
    CurrentStockExceedsTarget,
};
