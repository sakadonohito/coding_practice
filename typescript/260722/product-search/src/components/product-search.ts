export type Product = {
  id: string;
  name: string;
  price: number;
};

export type ProductSearchState =
  | {
      type: "idle";
    }
  | {
      type: "loading";
    }
  | {
      type: "success";
      products: Product[];
    }
  | {
      type: "empty";
      keyword: string;
    }
  | {
      type: "error";
      message: string;
    };

export type ProductSearcher = (
  keyword: string,
) => Promise<Product[]>;

export async function searchProducts(
  keyword: string,
  searcher: ProductSearcher,
): Promise<ProductSearchState> {
  const normalizedKeyword = keyword.trim();

  if (normalizedKeyword === "") {
    return {
      type: "empty",
      keyword: normalizedKeyword,
    };
  }

  try {
    const products =
      await searcher(normalizedKeyword);

    if (products.length === 0) {
      return {
        type: "empty",
        keyword: normalizedKeyword,
      };
    }

    return {
      type: "success",
      products,
    };
  } catch {
    return {
      type: "error",
      message: "商品の検索に失敗しました",
    };
  }
}

export function renderProductSearchState(
  state: ProductSearchState,
  statusElement: HTMLElement,
  listElement: HTMLUListElement,
  searchButton: HTMLButtonElement,
): void {
  listElement.replaceChildren();

  switch (state.type) {
    case "idle":
      statusElement.textContent =
        "商品名を入力してください";

      searchButton.disabled = false;
      return;

    case "loading":
      statusElement.textContent =
        "検索しています…";

      searchButton.disabled = true;
      return;

    case "empty":
      statusElement.textContent =
        state.keyword === ""
          ? "商品名を入力してください"
          : "該当する商品はありません";

      searchButton.disabled = false;
      return;

    case "error":
      statusElement.textContent =
        state.message;

      searchButton.disabled = false;
      return;

    case "success":
      statusElement.textContent =
        `${state.products.length}件見つかりました`;

      searchButton.disabled = false;

      for (const product of state.products) {
        const item =
          document.createElement("li");

        const name =
          document.createElement("span");

        const price =
          document.createElement("span");

        name.textContent = product.name;

        price.textContent =
          `${product.price.toLocaleString("ja-JP")}円`;

        item.append(name, price);
        listElement.append(item);
      }

      return;
  }
}
