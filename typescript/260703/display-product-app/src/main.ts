import { toDisplayProducts, type Product, type DisplayProduct } from "./utils/displayproducts";

const products: Product[] = [
  { id: 1, name: "ノート", price: 120 },
  { id: 2, name: "ペン", price: 80 },
  { id: 3, name: "ファイル", price: 200 },
];

const displayProducts: DisplayProduct[] = toDisplayProducts(products, 0.1);

console.log("=== result ===")
console.log(displayProducts);
console.log("=== finished ===")
