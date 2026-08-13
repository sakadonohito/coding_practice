export function createShoppingItem(itemName: string): HTMLLIElement {
  const shoppingItem = document.createElement("li");
  shoppingItem.className = "shopping-item";
  const span = document.createElement("span");
  span.textContent = itemName;
  const button = document.createElement("button");
  button.type = "button";
  button.textContent = "削除"
  button.setAttribute("aria-label", `「${itemName}」を削除`);
  shoppingItem.append(span, button);
  return shoppingItem;
}
