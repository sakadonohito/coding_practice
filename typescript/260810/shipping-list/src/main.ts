import "./styles.css";

import { validateItemName } from "./validation.ts";
import { createShoppingItem } from "./view.ts";

const form = document.querySelector<HTMLFormElement>("#item-form");
const input = document.querySelector<HTMLInputElement>("#item-name");
const itemList = document.querySelector<HTMLUListElement>("#item-list");
const statusMessage = document.querySelector<HTMLParagraphElement>(
  "#status-message",
);

if (!form || !input || !itemList || !statusMessage) {
  throw new Error("必要なDOM要素が見つかりません");
}

const itemNames: string[] = [];

function showMessage(message: string, kind: "success" | "error"): void {
  statusMessage!.textContent = message; //「!」の追加は、emacs の flymake 対策
  statusMessage!.dataset.kind = kind; //「!」の追加は、emacs の flymake 対策
}

function clearMessage(): void {
  statusMessage!.textContent = ""; //「!」の追加は、emacs の flymake 対策
  delete statusMessage!.dataset.kind;
  input!.removeAttribute("aria-invalid"); //「!」の追加は、emacs の flymake 対策
}

input.addEventListener("invalid", (event) => {
  event.preventDefault();
  showMessage("商品名を入力してください", "error");
  input.setAttribute("aria-invalid", "true");
  input.focus();

});

input.addEventListener("input", () => {
  clearMessage();
});

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const result = validateItemName(input.value, itemNames);
  if (!result.ok) {
    showMessage(result.message, "error");
    input.setAttribute("aria-invalid", "true");
    input.focus();
    return;
  } else {
    const itemName = result.value;
    itemNames.push(itemName);
    const itemElement = createShoppingItem(itemName);
    const deleteButton = itemElement.querySelector("button");
    if (!deleteButton) {
      throw new Error("Error!:Couldn't find delete button");
    }
    deleteButton.addEventListener("click", () => {
      const index = itemNames.indexOf(itemName);
      if (index >= 0) {
        itemNames.splice(index, 1);
      }
      itemElement.remove();
      showMessage(`「${itemName}」を削除しました`, "success");
      input.focus();
    });
    itemList.append(itemElement);
    input.value = "";
    showMessage(`「${itemName}」を追加しました`, "success");
    input.focus();
  }
});
