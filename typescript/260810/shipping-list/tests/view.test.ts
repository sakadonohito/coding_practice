import { describe, expect, it } from "vitest";

import { createShoppingItem } from "../src/view.ts";

describe("createShoppingItem", () => {
  it("商品名とアクセシブルな削除ボタンを持つliを返す", () => {
    const item = createShoppingItem("<strong>牛乳</strong>");
    expect(item.tagName).toBe("LI");
    expect(item.classList.contains("shopping-item")).toBe(true);
    const span = item.querySelector("span");
    expect(span?.textContent).toBe("<strong>牛乳</strong>");
    expect(item.querySelector("strong")).toBeNull();
    const button = item.querySelector("button");
    expect(button?.type).toBe("button");
    expect(button?.textContent).toBe("削除");
    expect(button?.getAttribute("aria-label")).toBe("「<strong>牛乳</strong>」を削除");
  });
});
