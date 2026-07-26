import "@/assets/style.css";

import {
  type Product,
  type ProductSearcher,
  renderProductSearchState,
  searchProducts,
} from "@/components/product-search";

const sampleProducts: Product[] = [
  {
    id: "product-001",
    name: "ワイヤレスキーボード",
    price: 6980,
  },
  {
    id: "product-002",
    name: "メカニカルキーボード",
    price: 12800,
  },
  {
    id: "product-003",
    name: "ワイヤレスマウス",
    price: 4980,
  },
];

const searcher: ProductSearcher =
  async (keyword) => {
    await new Promise<void>((resolve) => {
      window.setTimeout(resolve, 300);
    });

    return sampleProducts.filter((product) =>
      product.name.includes(keyword),
    );
  };

const form =
  document.querySelector<HTMLFormElement>(
    "#search-form",
  );

const keywordInput =
  document.querySelector<HTMLInputElement>(
    "#keyword",
  );

const searchButton =
  document.querySelector<HTMLButtonElement>(
    "#search-button",
  );

const statusElement =
  document.querySelector<HTMLElement>(
    "#status-message",
  );

const listElement =
  document.querySelector<HTMLUListElement>(
    "#product-list",
  );

if (
  form === null ||
  keywordInput === null ||
  searchButton === null ||
  statusElement === null ||
  listElement === null
) {
  throw new Error(
    "商品検索画面に必要なHTML要素がありません",
  );
}

renderProductSearchState(
  {
    type: "idle",
  },
  statusElement,
  listElement,
  searchButton,
);

form.addEventListener(
  "submit",
  async (event) => {
    event.preventDefault();

    renderProductSearchState(
      {
        type: "loading",
      },
      statusElement,
      listElement,
      searchButton,
    );

    const state = await searchProducts(
      keywordInput.value,
      searcher,
    );

    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
  },
);
