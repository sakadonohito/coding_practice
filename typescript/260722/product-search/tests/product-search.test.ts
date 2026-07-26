import {
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";

import {
  type ProductSearcher,
  type ProductSearchState,
  renderProductSearchState,
  searchProducts,
} from "@/components/product-search"

describe("searchProducts", () => {
  it("前後の空白を除去して商品を検索する", async () => {
    // ProductSearcher型のモック関数を作成してください。
    const searcher = vi.fn<ProductSearcher>();
    // モックが商品を1件返すようにしてください。
    searcher.mockResolvedValue([
      {
        id: "product-001",
        name: "キーボード",
        price: 6980,
      },
    ]);
    // キーワードとして" キーボード "を渡してください。
    const result = await searchProducts(
      " キーボード ",
      searcher,
    );
    // モックが"キーボード"で1回呼ばれたことを確認してください。
    expect(searcher).toHaveBeenCalledTimes(1);
    expect(searcher).toHaveBeenCalledWith("キーボード");
    // 結果がsuccessになることを確認してください。
    expect(result).toEqual({
      type: "success",
      products: [
        {
          id: "product-001",
          name: "キーボード",
          price: 6980,
        },
      ],
    });
  });

  it("空文字列なら検索処理を呼ばずemptyを返す", async () => {
    // ProductSearcher型のモック関数を作成してください。
    const searcher = vi.fn<ProductSearcher>();
    // 空白だけのキーワードを渡してください。
    const result = await searchProducts(
      "  　　  ",
      searcher,
    );
    // 結果が次になることを確認してください。
    // {
    //   type: "empty",
    //   keyword: "",
    // }
    expect(result).toEqual({
      type: "empty",
      keyword: "",
    });
    // モックが呼ばれていないことを確認してください。
    expect(searcher).not.toHaveBeenCalled();
  });

  it("検索結果が0件ならemptyを返す", async () => {
    const searcher = vi.fn<ProductSearcher>();
    // モックが空配列を返すようにしてください。
    searcher.mockResolvedValue([]);
    // "存在しない商品"で検索してください。
    const result = await searchProducts(
      "存在しない商品",
      searcher,
    );
    // 結果が次になることを確認してください。
    // {
    //   type: "empty",
    //   keyword: "存在しない商品",
    // }
    expect(result).toEqual({
      type: "empty",
      keyword: "存在しない商品",
    });
    expect(searcher).toHaveBeenCalledTimes(1);
  });

  it("検索処理が失敗したらerrorを返す", async () => {
    const searcher = vi.fn<ProductSearcher>();
    // モックがErrorをrejectするようにしてください。
    searcher.mockRejectedValue(
      new Error("通信失敗"),
    );
    // 結果が次になることを確認してください。
    // {
    //   type: "error",
    //   message: "商品の検索に失敗しました",
    // }
    const result = await searchProducts(
      "キーボード",
      searcher,
    );
    expect(result).toEqual({
      type: "error",
      message: "商品の検索に失敗しました",
    });
  });
});

describe("renderProductSearchState", () => {
  let statusElement: HTMLParagraphElement;
  let listElement: HTMLUListElement;
  let searchButton: HTMLButtonElement;

  beforeEach(() => {
    document.body.innerHTML = `
      <p id="status-message"></p>
      <ul id="product-list"></ul>
      <button id="search-button"></button>
    `;

    statusElement =
      document.querySelector<HTMLParagraphElement>(
        "#status-message",
      )!;

    listElement =
      document.querySelector<HTMLUListElement>(
        "#product-list",
      )!;

    searchButton =
      document.querySelector<HTMLButtonElement>(
        "#search-button",
      )!;
  });

  it("loadingでは検索中と表示してボタンを無効化する", () => {
    // loading状態を用意してください。
    const state: ProductSearchState = {
      type: "loading",
    };
    // renderProductSearchStateを呼んでください。
    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
    // statusElement.textContentが
    // "検索しています…"になることを確認してください。
    expect(statusElement.textContent).toBe("検索しています…")
    // searchButton.disabledがtrueになることを確認してください。
    expect(searchButton.disabled).toBe(true);
  });

  it("successでは商品一覧を表示する", () => {
    // 次の商品を持つsuccess状態を用意してください。
    //
    // {
    //   id: "product-001",
    //   name: "キーボード",
    //   price: 6980,
    // }
    const product = {
      id: "product-001",
      name: "キーボード",
      price: 6980,
    };
    const state: ProductSearchState = {
      type: "success",
      products: [
        product,
      ],
    };
    // renderProductSearchStateを呼んでください。
    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
    // statusElement.textContentが
    // "1件見つかりました"になることを確認してください。
    expect(statusElement.textContent).toBe("1件見つかりました");
    // listElement.children.lengthが1になることを確認してください。
    expect(listElement.children.length).toBe(1);
    // listElement.textContentに
    // "キーボード"と"6,980円"が含まれることを確認してください。
    expect(listElement.textContent).toEqual(
      expect.stringContaining("キーボード")
    );
    expect(listElement.textContent).toEqual(
      expect.stringContaining("6,980円")
    );
  });

  it("emptyでは該当商品なしと表示する", () => {
    // keywordが"マウスパッド"のempty状態を用意してください。
    const state: ProductSearchState = {
      type: "empty",
      keyword: "マウスパッド",
    };
    // renderProductSearchStateを呼んでください。
    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
    // statusElement.textContentが
    // "該当する商品はありません"
    // になることを確認してください。
    expect(statusElement.textContent).toBe("該当する商品はありません");
    // 商品一覧が空になることを確認してください。
    expect(listElement.children.length).toBe(0);
  });

  it("errorではエラーメッセージを表示する", () => {
    // 次のerror状態を用意してください。
    // {
    //   type: "error",
    //   message: "商品の検索に失敗しました",
    // }
    const state: ProductSearchState = {
      type: "error",
      message: "商品の検索に失敗しました",
    };
    // renderProductSearchStateを呼んでください。
    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
    // statusElement.textContentが
    // エラーメッセージになることを確認してください。
    expect(statusElement.textContent).toBe("商品の検索に失敗しました");
    // searchButton.disabledがfalseになることを確認してください。
    expect(searchButton.disabled).toBe(false);
  });

  it("再描画時に以前の商品一覧を削除する", () => {
    // listElementへ事前にli要素を1つ追加してください。
    const product = {
      id: "product-001",
      name: "キーボード",
      price: 6980,
    };
    let state: ProductSearchState = {
      type: "success",
      products: [
        product,
      ],
    };
    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
    expect(listElement.children.length).toBe(1);
    // idle状態を用意して、
    state = {
      type: "idle",
    };
    // renderProductSearchStateを呼んでください。
    renderProductSearchState(
      state,
      statusElement,
      listElement,
      searchButton,
    );
    // listElement.children.lengthが0になることを確認してください。
    expect(listElement.children.length).toBe(0);
  });
});
