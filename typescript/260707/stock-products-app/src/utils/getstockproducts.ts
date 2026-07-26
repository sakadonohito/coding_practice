export type Product = {
  name: string;
  price: number;
  inStock: boolean;
};

export function getInStockProducts(products: Product[]): Product[] {
  return products.filter((product) => product.inStock);
};
