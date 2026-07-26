/// <reference types="vitest/config" />
import { defineConfig } from "vite";

export default defineConfig({
  resolve: {
    tsconfigPaths: true
  },
  test: {
    globals: true,          // describe/it をグローバルに
    environment: "jsdom",   // DOM を使うなら jsdom、使わないなら "node"
    setupFiles: "./tests/setup.ts",
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
    },
  },
});
