import { describe, expect, test } from "vitest";
import { toUserResponses, type User } from "@/utils/responseuser";

describe("toUserResponses", () => {
  test("ユーザー一覧をAPIレスポンス用の形に変換できる", () => {
    // 1. isActive が true のユーザーと false のユーザーを1件ずつ用意してください。
    const users: User[] = [
      { id: 1, name: "Alice", email: "alice@example.com", isActive: true },
      { id: 2, name: "Bob", email: "bob@example.com", isActive: false },
    ];
    // 2. toUserResponses を呼び出してください。
    const result = toUserResponses(users);
    // 3. true のユーザーの status が "active" になることを確認してください。
    // 4. false のユーザーの status が "inactive" になることを確認してください。
    // 5. email がレスポンスに含まれないことを確認してください。
    expect(result).toEqual([
      { id: 1, displayName: "Alice", status: "active" },
      { id: 2, displayName: "Bob", status: "inactive" },
    ]);
    expect(result[0]).not.toHaveProperty("email");
  });

  test("空配列を渡した場合は空配列を返す", () => {
    // 1. 空のユーザー配列を用意してください。
    const users: User[] = [];
    // 2. toUserResponses を呼び出してください。
    const result = toUserResponses(users);
    // 3. 結果の要素数が 0 であることを確認してください。
    expect(result).toHaveLength(0);
  });
});

