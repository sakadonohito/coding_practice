const std = @import("std");
const stock_guard = @import("stock_guard");

const StockItem =
    stock_guard.stock_item.StockItem;

const Priority =
    stock_guard.stock_item.Priority;

const ReorderDecision =
    stock_guard.reorder_decision.ReorderDecision;

const evaluateReorder =
    stock_guard.reorder_service.evaluateReorder;

test "在庫が発注点より多ければ補充不要" {
    // 要件:
    // 商品コード:
    // "ITEM-001"
    // 現在庫:
    // 8
    // 発注点:
    // 5
    // 目標在庫:
    // 15
    // 優先度:
    // normal
    // evaluateReorderを実行する。
    // 結果がno_reorderであることを確認する。
    // product_code:
    // "ITEM-001"
    // current_stock:
    // 8

    // 1. テスト対象の入力データ (StockItem) を作成する
    const item: StockItem = .{
        .product_code = "ITEM-001",
        .current_stock = 8,
        .reorder_point = 5,
        .target_stock = 15,
        .priority = .normal,
        .discontinued = false,
    };
    // 2. 判定関数を実行する
    const decision = evaluateReorder(item);
    // 3. 結果 (decision) が .no_reorder であり、中身の値が期待通りか検証する
    switch (decision) {
        .no_reorder => |no_reorder| {
            try std.testing.expectEqualStrings("ITEM-001", no_reorder.product_code);
            try std.testing.expectEqual(@as(u32, 8), no_reorder.current_stock);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "在庫が発注点以下なら通常補充" {
    // 要件:
    // 商品コード:
    // "ITEM-002"
    // 現在庫:
    // 3
    // 発注点:
    // 5
    // 目標在庫:
    // 12
    // 優先度:
    // normal
    // 結果がstandard_reorderである。
    // order_quantity:
    // 12 - 3 = 9

    // 1. テスト対象の入力データ (StockItem) を作成する
    const item: StockItem = .{
        .product_code = "ITEM-002",
        .current_stock = 3,
        .reorder_point = 5,
        .target_stock = 12,
        .priority = .normal,
        .discontinued = false,
    };
    // 2. 判定関数を実行する
    const decision = evaluateReorder(item);
    // 3. 結果 (decision) が .no_reorder であり、中身の値が期待通りか検証する
    switch (decision) {
        .standard_reorder => |reorder| {
            try std.testing.expectEqualStrings("ITEM-002", reorder.product_code);
            try std.testing.expectEqual(@as(u32, 9), reorder.order_quantity);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "在庫ゼロなら緊急補充" {
    // 要件:
    // 現在庫:
    // 0
    // 発注点:
    // 5
    // 目標在庫:
    // 10
    // 結果がurgent_reorderである。
    // order_quantity:
    // 10
    // reason:
    // "out of stock"

    // 1. テスト対象の入力データ (StockItem) を作成する
    const item: StockItem = .{
        .product_code = "ITEM-003",
        .current_stock = 0,
        .reorder_point = 5,
        .target_stock = 10,
        .priority = .normal,
        .discontinued = false,
    };
    // 2. 判定関数を実行する
    const decision = evaluateReorder(item);
    // 3. 結果 (decision) が .no_reorder であり、中身の値が期待通りか検証する
    switch (decision) {
        .urgent_reorder => |reorder| {
            try std.testing.expectEqualStrings("ITEM-003", reorder.product_code);
            try std.testing.expectEqual(@as(u32, 10), reorder.order_quantity);
            try std.testing.expectEqualStrings("out of stock", reorder.reason);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "高優先度商品なら在庫が残っていても緊急補充" {
    // 要件:
    // 現在庫:
    // 2
    // 発注点:
    // 5
    // 目標在庫:
    // 10
    // 優先度:
    // high
    // 結果がurgent_reorderである。
    // reason:
    // "high priority product"

    // 1. テスト対象の入力データ (StockItem) を作成する
    const item: StockItem = .{
        .product_code = "ITEM-004",
        .current_stock = 2,
        .reorder_point = 5,
        .target_stock = 10,
        .priority = .high,
        .discontinued = false,
    };
    // 2. 判定関数を実行する
    const decision = evaluateReorder(item);
    // 3. 結果 (decision) が .no_reorder であり、中身の値が期待通りか検証する
    switch (decision) {
        .urgent_reorder => |reorder| {
            try std.testing.expectEqualStrings("ITEM-004", reorder.product_code);
            try std.testing.expectEqual(@as(u32, 8), reorder.order_quantity);
            try std.testing.expectEqualStrings("high priority product", reorder.reason);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "廃番商品は補充を拒否" {
    // 要件:
    // discontinued:
    // true
    // 結果がrejectedである。
    // reason:
    // "discontinued product"

    // 1. テスト対象の入力データ (StockItem) を作成する
    const item: StockItem = .{
        .product_code = "ITEM-005",
        .current_stock = 10,
        .reorder_point = 5,
        .target_stock = 10,
        .priority = .normal,
        .discontinued = true,
    };
    // 2. 判定関数を実行する
    const decision = evaluateReorder(item);
    // 3. 結果 (decision) が .no_reorder であり、中身の値が期待通りか検証する
    switch (decision) {
        .rejected => |rejected| {
            try std.testing.expectEqualStrings("ITEM-005", rejected.product_code);
            try std.testing.expectEqualStrings("discontinued product", rejected.reason);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "空の商品コードは入力不正" {
    // 要件:
    // product_code:
    // "   "
    // 結果がrejectedである。
    // reason:
    // "product code must not be blank"

    // 1. テスト対象の入力データ (StockItem) を作成する
    const item: StockItem = .{
        .product_code = "   ",
        .current_stock = 10,
        .reorder_point = 5,
        .target_stock = 10,
        .priority = .normal,
        .discontinued = false,
    };
    // 2. 判定関数を実行する
    const decision = evaluateReorder(item);
    // 3. 結果 (decision) が .no_reorder であり、中身の値が期待通りか検証する
    switch (decision) {
        .rejected => |rejected| {
            try std.testing.expectEqualStrings("   ", rejected.product_code);
            try std.testing.expectEqualStrings("product code must not be blank", rejected.reason);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "複数の補充ケースを検証する" {
    // 要件:
    // Caseというテスト用structを定義する。
    // フィールド:
    // name
    // item
    // expected_tag
    //
    // 次の3ケースを配列にする。
    //
    // 1. 補充不要
    // current_stock: 8
    // reorder_point: 5
    //
    // 2. 通常補充
    // current_stock: 3
    // reorder_point: 5
    //
    // 3. 緊急補充
    // current_stock: 0
    // reorder_point: 5
    //
    // forを使って各ケースを実行する。
    // std.meta.activeTag()で
    // Tagged Unionの現在のタグを取得する。
    // expectEqualで期待タグと比較する。

    const DecisionTag = std.meta.Tag(ReorderDecision);

    const Case = struct {
        name: []const u8,
        item: StockItem,
        expected_tag: DecisionTag,
    };

    const cases = [_]Case{
        .{
            .name = "補充不要",
            .item = .{
                .product_code = "ITEM-001",
                .current_stock = 8,
                .reorder_point = 5,
                .target_stock = 15,
                .priority = .normal,
                .discontinued = false,
            },
            .expected_tag = .no_reorder,
        },
        .{
            .name = "通常補充",
            .item = .{
                .product_code = "ITEM-002",
                .current_stock = 3,
                .reorder_point = 5,
                .target_stock = 15,
                .priority = .normal,
                .discontinued = false,
            },
            .expected_tag = .standard_reorder,
        },
        .{
            .name = "緊急補充",
            .item = .{
                .product_code = "ITEM-002",
                .current_stock = 0,
                .reorder_point = 5,
                .target_stock = 15,
                .priority = .normal,
                .discontinued = false,
            },
            .expected_tag = .urgent_reorder,
        },
    };

    for (cases) |tc| {
        const actual = evaluateReorder(tc.item);

        try std.testing.expectEqual(
            tc.expected_tag,
            std.meta.activeTag(actual),
        );
    }
}
