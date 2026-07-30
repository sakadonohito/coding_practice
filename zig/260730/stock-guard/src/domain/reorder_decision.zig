pub const ReorderDecision = union(enum) {
    no_reorder: NoReorder,
    standard_reorder: StandardReorder,
    urgent_reorder: UrgentReorder,
    rejected: Rejected,

    pub const NoReorder = struct {
        product_code: []const u8,
        current_stock: u32,
    };

    pub const StandardReorder = struct {
        product_code: []const u8,
        order_quantity: u32,
    };

    pub const UrgentReorder = struct {
        product_code: []const u8,
        order_quantity: u32,
        reason: []const u8,
    };

    pub const Rejected = struct {
        product_code: []const u8,
        reason: []const u8,
    };
};
