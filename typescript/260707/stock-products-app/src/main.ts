import { getInStockProducts, type Product } from "./utils/getstockproducts";

const products: Product[] = [
  { name: "ノート", price: 120, inStock: true },
  { name: "ペン", price: 80, inStock: false },
  { name: "消しゴム", price: 60, inStock: true },
];

const result = getInStockProducts(products);

console.log("==========");
console.log(result);
console.log("==========");
