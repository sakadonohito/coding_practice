export const MAX_ITEM_NAME_LENGTH = 40;

export type ItemNameValidation =
  | Readonly<{
      ok: true;
      value: string;
    }>
  | Readonly<{
      ok: false;
      message: string;
    }>;

export function validateItemName(
  rawName: string,
  existingNames: readonly string[],
): ItemNameValidation {
  const normalizedName = rawName.trim();
  if (normalizedName === "") {
    return {ok: false, message: "商品名を入力してください"};
  }
  if (normalizedName.length > MAX_ITEM_NAME_LENGTH) {
    return {ok: false, message: `商品名は${MAX_ITEM_NAME_LENGTH}文字以内で入力してください`};
  }
  const duplicated = existingNames.some((existingName) => {
    return existingName.toLocaleLowerCase() === normalizedName.toLocaleLowerCase();
  });
  if (duplicated) {
    return {ok: false, message: "その商品はすでに追加されています"};
  }
  return { ok: true, value: normalizedName };
}
