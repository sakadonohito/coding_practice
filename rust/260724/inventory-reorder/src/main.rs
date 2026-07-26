use inventory_reorder::{
    evaluate_inventory,
    InventoryDecision,
    InventoryItem,
};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let item = InventoryItem::new(
        "ITEM-001",
        3,
        10,
        2,
    )?;

    let decision = evaluate_inventory(&item)?;

    println!("商品コード: {}", item.product_code());

    match decision {
        InventoryDecision::Sufficient => {
            println!("判定: 在庫は十分です");
        }

        InventoryDecision::WaitingForIncomingStock => {
            println!("判定: 発注済み商品の入荷待ちです");
        }

        InventoryDecision::ReorderRequired {
            recommended_quantity,
        } => {
            println!("判定: 追加発注が必要です");
            println!(
                "推奨発注数量: {recommended_quantity}"
            );
        }
    }

    Ok(())
}
