//import { defineConfig } from "vitest/config";
import { defineConfig } from "vite";

export default defineConfig({
  resolve: {
    tsconfigPaths: true
  },
  test: {
    globals: true,          // describe/it をグローバルに
    environment: "jsdom",
    setupFiles: "./tests/setup.ts",
    clearMocks: true,
    //include: [
    //  "tests/**/*.test.ts",
    //],
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
    },
  },
});
