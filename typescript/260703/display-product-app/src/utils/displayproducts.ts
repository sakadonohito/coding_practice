export type Product = {
  id: number;
  name: string;
  price: number;
};

export type DisplayProduct = {
  id: number;
  label: string;
  taxIncludedPrice: number;
};

export function toDisplayProducts(products: Product[], taxRate: number): DisplayProduct[] {
  return products.map((product) => {
    const taxIncludedPrice = Math.floor(product.price * (1 + taxRate));

    return {
      id: product.id,
      label: `${product.name} - ${taxIncludedPrice}円`,
      taxIncludedPrice: taxIncludedPrice,
    }
  });
}
