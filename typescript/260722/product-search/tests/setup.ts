// tests/setup.ts
import { afterEach, vi } from "vitest";

// 各テスト後にモックをリセット
afterEach(() => {
  vi.clearAllMocks();
});
