import { describe, expect, test } from "vitest";
import { toDisplayProducts, type Product } from "@/utils/displayproducts";

describe("toDisplayProducts", () => {
  test("商品一覧を税込価格つきの表示データに変換できる", () => {
    // 1. price が 100, 200 の商品配列を用意してください。
    const products: Product[] = [
      { id: 1, name: "ノート", price: 100 },
      { id: 2, name: "ペン", price: 200 },
    ];
    // 2. taxRate に 0.1 を指定して toDisplayProducts を呼び出してください。
    const displayProducts = toDisplayProducts(products, 0.1);
    // 3. taxIncludedPrice が 110, 220 になることを確認してください。
    // 4. label が「商品名 - 税込価格円」の形になることを確認してください。
    expect(displayProducts).toEqual([
      { id: 1, label: "ノート - 110円", taxIncludedPrice: 110 },
      { id: 2, label: "ペン - 220円", taxIncludedPrice: 220 },
    ]);
  });

  test("空配列を渡した場合は空配列を返す", () => {
    // 1. 空の Product 配列を用意してください。
    const products: Product[] = [];
    // 2. toDisplayProducts を呼び出してください。
    const displayProducts = toDisplayProducts(products, 0.1);
    // 3. 結果が空配列であることを確認してください。
    expect(displayProducts).toHaveLength(0);
  });
});
