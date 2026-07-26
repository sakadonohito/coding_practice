import { describe, it, expect } from "vitest";
import { add } from "./math";

describe("add", () => {
  it("2つの数値を足し算できる", () => {
    expect(add(1, 2)).toBe(3);
  });
});
