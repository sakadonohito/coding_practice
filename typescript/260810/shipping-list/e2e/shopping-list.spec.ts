import { expect, test } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/");
});

test("商品を追加し、入力欄へフォーカスを戻す", async ({ page }) => {
  const input = page.getByLabel("商品名");
  await input.fill("  牛乳  ");
  await page.getByRole("button", { name: "商品を追加" }).click();
  const listItems = page.getByRole("listitem");
  await expect(listItems).toHaveCount(1);
  await expect(listItems).toContainText("牛乳");
  await expect(page.locator("#status-message")).toHaveText("「牛乳」を追加しました");
  await expect(input).toHaveValue("");
  await expect(input).toBeFocused();
});

test("空の商品名ではnative validationのエラーを通知する", async ({
  page,
}) => {
  const input = page.getByLabel("商品名");
  await page.getByRole("button", { name: "商品を追加" }).click();
  const isValueMissing = await input.evaluate(
    (element: HTMLInputElement) => element.validity.valueMissing
  );
  expect(isValueMissing).toBe(true);
});

test("重複を拒否し、削除後は同じ商品を再追加できる", async ({
  page,
}) => {
  const input = page.getByLabel("商品名");

  await input.fill("Milk");
  await page.getByRole("button", { name: "商品を追加" }).click();

  await input.fill("milk");
  await page.getByRole("button", { name: "商品を追加" }).click();

  const listItems = page.getByRole("listitem");
  await expect(listItems).toHaveCount(1);
  await expect(page.locator("#status-message")).toHaveText("その商品はすでに追加されています");

  await page.getByRole("button", { name: "「Milk」を削除" }).click();
  await expect(listItems).toHaveCount(0);
  await expect(page.locator("#status-message")).toHaveText("「Milk」を削除しました");

  await input.fill("milk");
  await page.getByRole("button", { name: "商品を追加" }).click();
  await expect(listItems).toHaveCount(1);
  await expect(listItems).toContainText("milk");
});
