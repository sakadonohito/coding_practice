use inventory_reorder::{
    evaluate_inventory,
    InventoryDecision,
    InventoryError,
    InventoryItem,
};

#[test]
fn sufficient_when_current_stock_reaches_safety_stock() {
    // TODO: 次の要件を満たすテストを実装する。
    // 商品コード:   "ITEM-001"
    // 現在庫:      10
    // 安全在庫:    10
    // 発注済み数量: 0
    // InventoryItem::newが成功することを確認する。
    // evaluate_inventoryの結果が次と等しいことを確認する。
    // InventoryDecision::Sufficient
    let item = InventoryItem::new(
        "ITEM-001",
        10,
        10,
        0,
    )
        .expect("有効な入力なのでInventoryItemの生成に成功するはず");
    let got = evaluate_inventory(&item)
        .expect("有効な在庫情報なので判定に成功するはず");
    let want = InventoryDecision::Sufficient;
    assert_eq!(got, want)
}

#[test]
fn waits_when_incoming_stock_covers_shortage() {
    // TODO: 次の要件を満たすテストを実装する。
    // 商品コード:    "ITEM-002"
    // 現在庫:        4
    // 安全在庫:      10
    // 発注済み数量:   6
    // 現在庫だけでは安全在庫を下回る。
    // ただし、
    // 現在庫4 + 発注済み6 = 10
    // となるため、結果が次と等しいことを確認する。
    // InventoryDecision::WaitingForIncomingStock
    let item = InventoryItem::new(
        "ITEM-002",
        4,
        10,
        6,
    )
        .expect("有効な入力なのでInventoryItemの生成に成功するはず");
    let got = evaluate_inventory(&item)
        .expect("現在庫4 + 発注済み6 = 10なので判定に成功するはず");
    let want = InventoryDecision::WaitingForIncomingStock;
    assert_eq!(got, want)
}

#[test]
fn recommends_quantity_not_covered_by_incoming_stock() {
    // TODO: 次の要件を満たすテストを実装する。
    // 商品コード:
    // "ITEM-003"
    // 現在庫:
    // 3
    // 安全在庫:
    // 10
    // 発注済み数量:
    // 2
    // 推奨発注数量は次の計算になる。
    // 10 - 3 - 2 = 5
    // 結果が次と等しいことを確認する。
    // InventoryDecision::ReorderRequired {
    //     recommended_quantity: 5,
    // }
    let item = InventoryItem::new(
        "ITEM-003",
        3,
        10,
        2,
    )
        .expect("有効な入力なのでInventoryItemの生成に成功するはず");
    let got = evaluate_inventory(&item)
        .expect("推奨発注5となるはず");
    let want = InventoryDecision::ReorderRequired {
        recommended_quantity: 5,
    };
    assert_eq!(got, want)
}

#[test]
fn rejects_empty_product_code() {
    // TODO: 次の要件を満たすテストを実装する。
    // 商品コードに空文字を指定する。
    // 現在庫:
    // 1
    // 安全在庫:
    // 5
    // 発注済み数量:
    // 0
    // InventoryItem::newの結果が次のエラーであることを
    // 確認する。
    // InventoryError::EmptyProductCode
    let item = InventoryItem::new(
        "",
        1,
        5,
        0,
    )
        .expect_err("存在しない在庫設定なので失敗するはず");
    let want = InventoryError::EmptyProductCode;
    assert_eq!(item, want)
}

#[test]
fn rejects_negative_current_stock() {
    // TODO: 次の要件を満たすテストを実装する。
    // 商品コード:
    // "ITEM-005"
    // 現在庫:
    // -1
    // 安全在庫:
    // 5
    // 発注済み数量:
    // 0
    // InventoryItem::newの結果が次のエラーであることを
    // 確認する。
    // InventoryError::NegativeCurrentStock(-1)
    let item = InventoryItem::new(
        "ITEM-005",
        -1,
        5,
        0,
    )
        .expect_err("在庫不足設定なので失敗するはず");
    let want = InventoryError::NegativeCurrentStock(-1);
    assert_eq!(item, want)
}

#[test]
fn evaluates_multiple_inventory_cases() {
    // TODO: 複数の正常系をまとめてテストする。
    // testsという配列またはVecを作り、各要素に次を持たせる。
    // name:
    // テストケース名
    // item:
    // InventoryItem
    // expected:
    // 期待するInventoryDecision
    //
    // ケース1:
    // name: "在庫が安全在庫を上回る"
    // 現在庫: 20
    // 安全在庫: 10
    // 発注済み数量: 0
    // 期待値: InventoryDecision::Sufficient
    //
    // ケース2:
    // name: "発注済み数量で不足を補える"
    // 現在庫: 5
    // 安全在庫: 10
    // 発注済み数量: 7
    // 期待値:
    // InventoryDecision::WaitingForIncomingStock
    //
    // ケース3:
    // name: "追加発注が必要"
    // 現在庫: 2
    // 安全在庫: 10
    // 発注済み数量: 3
    // 期待値:
    // InventoryDecision::ReorderRequired {
    //     recommended_quantity: 5,
    // }
    //
    // forループで各ケースを処理する。
    // assert_eq!には、テストケース名を失敗メッセージとして
    // 渡す。

    struct TestCase {
        name: &'static str,
        item: InventoryItem,
        expected: InventoryDecision,
    }

    let tests = [
        TestCase {
            name: "在庫が安全在庫を上回る",
            item: InventoryItem::new("ITEM-001", 20, 10, 0).expect("有効なはず"),
            expected: InventoryDecision::Sufficient,
        },
        TestCase {
            name: "発注済み数量で不足を補える",
            item: InventoryItem::new("ITEM-002", 5, 10, 7).expect("有効なはず"),
            expected: InventoryDecision::WaitingForIncomingStock,
        },
        TestCase {
            name: "追加発注が必要",
            item: InventoryItem::new("ITEM-003", 2, 10, 3).expect("有効なはず"),
            expected: InventoryDecision::ReorderRequired {
                recommended_quantity: 5,
            },
        },
    ];

    for tc in tests {
        let got = evaluate_inventory(&tc.item).expect("有効なはず");
        assert_eq!(got, tc.expected, "FAILED [{}]: got={:?}, expected={:?}", tc.name, got, tc.expected)
    }
}
