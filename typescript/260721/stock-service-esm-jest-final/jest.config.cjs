const { createDefaultEsmPreset } = require("ts-jest");

const preset = createDefaultEsmPreset({
  tsconfig: "<rootDir>/tsconfig.json",
});

/** @type {import("jest").Config} */
module.exports = {
  ...preset,
  testEnvironment: "node",
  roots: ["<rootDir>/src"],
  testMatch: ["**/*.test.ts"],
  clearMocks: true,
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1",
  },
};
