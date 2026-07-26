export type ProductStock = {
  productId: string;
  quantity: number;
}

export type ReserveStockCommand = {
  productId: string;
  quantity: number;
}

export type StockReservation = {
  productId: string;
  reservedQuantity: number;
  remainingStock: number;
}

export type ReserveStockResult =
  | {
    type: "success";
    reservation: StockReservation;
  }
  | {
    type: "invalidQuantity";
    quantity: number;
  }
  | {
    type: "productNotFound";
    productId: string;
  }
  | {
    type: "insufficientStock";
    productId: string;
    requestedQuantity: number;
    availableQuantity: number;
  };

export interface StockRepository {
  findByProductId(
    productId: string,
  ): Promise<ProductStock | null>;

  save(stock: ProductStock): Promise<void>;
}

export async function reserveStock(
  repository: StockRepository,
  command: ReserveStockCommand,
): Promise<ReserveStockResult> {
  if (!Number.isInteger(command.quantity) || command.quantity <= 0) {
    return {
      type: "invalidQuantity",
      quantity: command.quantity,
    };
  }

  const stock = await repository.findByProductId(
    command.productId,
  );

  if (stock === null) {
    return {
      type: "productNotFound",
      productId: command.productId,
    };
  }

  if (stock.quantity < command.quantity) {
    return {
      type: "insufficientStock",
      productId: command.productId,
      requestedQuantity: command.quantity,
      availableQuantity: stock.quantity,
    };
  }

  const updatedStock: ProductStock = {
    ...stock,
    quantity: stock.quantity - command.quantity,
  };

  await repository.save(updatedStock);

  return {
    type: "success",
    reservation: {
      productId: stock.productId,
      reservedQuantity: command.quantity,
      remainingStock: updatedStock.quantity,
    },
  };
}
