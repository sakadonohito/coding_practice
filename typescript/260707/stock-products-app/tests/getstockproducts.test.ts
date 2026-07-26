import { describe, expect, test } from "vitest";
import { getInStockProducts, type Product } from "@/utils/getstockproducts";

describe("getInStockProducts", () => {
  test("在庫ありの商品だけを返す", () => {
    // 1. inStock が true の商品と false の商品を混ぜて用意してください。
    const products: Product[] = [
      { name: "ノート", price: 120, inStock: true },
      { name: "ペン", price: 80, inStock: false },
      { name: "消しゴム", price: 60, inStock: true },
    ];
    // 2. getInStockProducts を呼び出してください。
    const result = getInStockProducts(products);
    // 3. 戻り値に inStock が true の商品だけ含まれることを確認してください。
    expect(result).toEqual([
      { name: "ノート", price: 120, inStock: true },
      { name: "消しゴム", price: 60, inStock: true },
    ]);
  });

  test("在庫ありの商品だけを返す:1つもない", () => {
    // 1. inStock が true の商品と false の商品を混ぜて用意してください。
    const products: Product[] = [
      { name: "ノート", price: 120, inStock: false },
      { name: "ペン", price: 80, inStock: false },
      { name: "消しゴム", price: 60, inStock: false },
    ];
    // 2. getInStockProducts を呼び出してください。
    const result = getInStockProducts(products);
    // 3. 戻り値に inStock が true の商品だけ含まれることを確認してください。
    expect(result).toHaveLength(0);
  });

  test("空の商品一覧なら空配列を返す", () => {
    // 1. 空の Product[] を用意してください。
    const products: Product[] = [];
    // 2. getInStockProducts を呼び出してください。
    const result = getInStockProducts(products);
    // 3. 戻り値が空配列であることを確認してください。
    expect(result).toHaveLength(0);
  });
});
