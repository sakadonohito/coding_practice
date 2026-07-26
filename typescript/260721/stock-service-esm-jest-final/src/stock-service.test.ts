import { beforeEach, describe, expect, jest, test } from "@jest/globals";

import {
  type ProductStock,
  type StockRepository,
  reserveStock,
} from "./stock-service.js";

describe("reserveStock", () => {
  let findByProductId: jest.MockedFunction<
    StockRepository["findByProductId"]
  >;
  let save: jest.MockedFunction<StockRepository["save"]>;
  let repository: StockRepository;

  beforeEach(() => {
    findByProductId = jest.fn<StockRepository["findByProductId"]>();
    save = jest.fn<StockRepository["save"]>();

    repository = {
      findByProductId,
      save,
    };
  });

  test("在庫が十分なら在庫を引き当てて成功結果を返す", async () => {
    findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });

    const result = await reserveStock(repository, {
      productId: "product-001",
      quantity: 3,
    });

    expect(result).toEqual({
      type: "success",
      reservation: {
        productId: "product-001",
        reservedQuantity: 3,
        remainingStock: 7,
      },
    });

    expect(save).toHaveBeenCalledTimes(1);
    expect(save).toHaveBeenCalledWith({
      productId: "product-001",
      quantity: 7,
    } satisfies ProductStock);
  });

  test("注文数量が0ならinvalidQuantityを返す", async () => {
    const result = await reserveStock(repository, {
      productId: "product-001",
      quantity: 0,
    });

    expect(result).toEqual({
      type: "invalidQuantity",
      quantity: 0,
    });
    expect(findByProductId).not.toHaveBeenCalled();
    expect(save).not.toHaveBeenCalled();
  });

  test("注文数量が小数ならinvalidQuantityを返す", async () => {
    const result = await reserveStock(repository, {
      productId: "product-001",
      quantity: 1.5,
    });

    expect(result).toEqual({
      type: "invalidQuantity",
      quantity: 1.5,
    });
    expect(findByProductId).not.toHaveBeenCalled();
    expect(save).not.toHaveBeenCalled();
  });

  test("商品が存在しなければproductNotFoundを返す", async () => {
    findByProductId.mockResolvedValue(null);

    const result = await reserveStock(repository, {
      productId: "unknown-product",
      quantity: 1,
    });

    expect(result).toEqual({
      type: "productNotFound",
      productId: "unknown-product",
    });
    expect(save).not.toHaveBeenCalled();
  });

  test("在庫が不足していればinsufficientStockを返す", async () => {
    findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 2,
    });

    const result = await reserveStock(repository, {
      productId: "product-001",
      quantity: 3,
    });

    expect(result).toEqual({
      type: "insufficientStock",
      productId: "product-001",
      requestedQuantity: 3,
      availableQuantity: 2,
    });
    expect(save).not.toHaveBeenCalled();
  });

  test("在庫と注文数量が同じなら残り在庫0で成功する", async () => {
    findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 5,
    });

    const result = await reserveStock(repository, {
      productId: "product-001",
      quantity: 5,
    });

    expect(result).toEqual({
      type: "success",
      reservation: {
        productId: "product-001",
        reservedQuantity: 5,
        remainingStock: 0,
      },
    });
    expect(save).toHaveBeenCalledWith({
      productId: "product-001",
      quantity: 0,
    });
  });

  test("商品IDを使って在庫を検索する", async () => {
    findByProductId.mockResolvedValue({
      productId: "product-001",
      quantity: 10,
    });

    await reserveStock(repository, {
      productId: "product-001",
      quantity: 1,
    });

    expect(findByProductId).toHaveBeenCalledTimes(1);
    expect(findByProductId).toHaveBeenCalledWith("product-001");
  });
});
