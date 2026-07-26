import { describe, test, expect, beforeEach, vi, type Mocked, type MockedFunction } from "vitest";
import {
  type StockRepository,
  reserveStock,
  type ProductStock,
} from "./stock-service.js";

describe("reserveStock", () => {
  let repository: Mocked<StockRepository>;

  //let save: MockedFunction<StockRepository["save"]>;
  //let findByProductId: MockedFunction<StockRepository["findByProductId"]>;

  beforeEach(() => {
    repository = {
      findByProductId: vi.fn(),
      save: vi.fn(),
    };
  });

  test("在庫を引き当てられる", async () => {
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });

    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 3,
      },
    );

    expect(result).toEqual({
      type: "success",
      reservation: {
        productId: "product-001",
        reservedQuantity: 3,
        remainingStock: 7,
      },
    });
  });

  test("在庫が十分なら在庫を引き当てて成功結果を返す", async () => {
    // 商品product-001の在庫が10個ある状態を設定してください。
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });
    // product-001を3個引き当ててください。
    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 3,
      }
    );
    // 結果が次になることを確認してください。
    // {
    //   type: "success",
    //   reservation: {
    //     productId: "product-001",
    //     reservedQuantity: 3,
    //     remainingStock: 7,
    //   },
    // }
    expect(result).toEqual({
      type: "success",
      reservation: {
        productId: "product-001",
        reservedQuantity: 3,
        remainingStock: 7,
      }
    });
    // repository.saveが次の値で1回呼ばれたことを確認してください。
    expect(repository.save).toHaveBeenCalledTimes(1);
    // {
    //   productId: "product-001",
    //   quantity: 7,
    // }
    expect(repository.save).toHaveBeenCalledWith({
      productId: "product-001",
      quantity: 7,
    } satisfies ProductStock);
  });

  test("注文数量が0ならinvalidQuantityを返す", async () => {
    // 注文数量0を渡してください。
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });
    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 0,
      }
    );
    // 結果が次になることを確認してください。
    //
    // {
    //   type: "invalidQuantity",
    //   quantity: 0,
    // }
    //
    expect(result).toEqual({
      type: "invalidQuantity",
      quantity: 0,
    });
    // findByProductIdが呼ばれていないことを確認してください。
    expect(repository.findByProductId).not.toHaveBeenCalled();
    // saveが呼ばれていないことを確認してください。
    expect(repository.save).not.toHaveBeenCalled();
  });

  test("注文数量が小数ならinvalidQuantityを返す", async () => {
    // 注文数量1.5を渡してください。
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });
    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 1.5,
      }
    );
    // 結果がinvalidQuantityになることを確認してください。
    expect(result).toEqual({
      type: "invalidQuantity",
      quantity: 1.5,
    });
    // findByProductIdが呼ばれていないことを確認してください。
    expect(repository.findByProductId).not.toHaveBeenCalled();
  });

  test("商品が存在しなければproductNotFoundを返す", async () => {
    //repository.findByProductId.mockResolvedValue({
    //  productId: "product-001",
    //  quantity: 10,
    //});
    repository.findByProductId.mockResolvedValue(null);
    // findByProductIdがnullを返すように設定してください。
    // unknown-productを1個引き当ててください。
    const result = await reserveStock(
      repository,
      {
        productId: "unknown-product",
        quantity: 1,
      }
    );
    // 結果が次になることを確認してください。
    // {
    //   type: "productNotFound",
    //   productId: "unknown-product",
    // }
    expect(result).toEqual({
      type: "productNotFound",
      productId: "unknown-product",
    });
    // saveが呼ばれていないことを確認してください。
    expect(repository.save).not.toHaveBeenCalled();
  });

  test("在庫が不足していればinsufficientStockを返す", async () => {
    // product-001の在庫が2個ある状態を設定してください。
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 2,
    });
    // 3個引き当ててください。
    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 3,
      }
    );
    // 結果が次になることを確認してください。
    // {
    //   type: "insufficientStock",
    //   productId: "product-001",
    //   requestedQuantity: 3,
    //   availableQuantity: 2,
    // }
    expect(result).toEqual({
      type: "insufficientStock",
      productId: "product-001",
      requestedQuantity: 3,
      availableQuantity: 2,
    });
    // saveが呼ばれていないことを確認してください。
    expect(repository.save).not.toHaveBeenCalled();
  });

  test("在庫と注文数量が同じなら残り在庫0で成功する", async () => {
    // product-001の在庫が5個ある状態を設定してください。
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 5,
    });
    // 5個引き当ててください。
    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 5,
      }
    );
    // 成功結果のremainingStockが0になることを確認してください。
    expect(result).toEqual({
      type: "success",
      reservation: {
        productId: "product-001",
        reservedQuantity: 5,
        remainingStock: 0,
      },
    });
    // repository.saveがquantity: 0の在庫で呼ばれたことを確認してください。
    expect(repository.save).toHaveBeenCalledWith({
      productId: "product-001",
      quantity: 0,
    } satisfies ProductStock);
  });

  test("商品IDを使って在庫を検索する", async () => {
    // findByProductIdが商品在庫を返すように設定してください。
    repository.findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });
    // product-001を1個引き当ててください。
    const result = await reserveStock(
      repository,
      {
        productId: "product-001",
        quantity: 1,
      }
    );
    // findByProductIdが"product-001"を引数として
    // 1回呼ばれたことを確認してください。
    expect(repository.findByProductId).toHaveBeenCalledTimes(1);
    expect(repository.findByProductId).toHaveBeenCalledWith("product-001");

  });
});
