import { describe, expect, it } from "vitest";

import {
  MAX_ITEM_NAME_LENGTH,
  validateItemName,
} from "../src/validation.ts";

describe("validateItemName", () => {
  it("前後の空白を取り除いて正常値を返す", () => {
    const actual = validateItemName("  牛乳  ", []);
    const expected = { ok: true, value: "牛乳" };
    expect(actual).toEqual(expected);
  });

  it("空白だけの商品名を拒否する", () => {
    const actual = validateItemName("   ", []);
    const expected = { ok: false, message: "商品名を入力してください" };
    expect(actual).toEqual(expected);
  });

  it("40文字を超える商品名を拒否する", () => {
    const actual = validateItemName("あ".repeat(MAX_ITEM_NAME_LENGTH + 1), []);
    const expected = { ok: false, message: "商品名は40文字以内で入力してください" };
    expect(actual).toEqual(expected);
  });

  it("大文字と小文字を区別せず重複を拒否する", () => {
    const actual = validateItemName("milk", ["MILK"]);
    const expected = { ok: false, message: "その商品はすでに追加されています" };
    expect(actual).toEqual(expected);
  });
});
