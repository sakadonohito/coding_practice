import { describe, expect, test } from "vitest";
import {
  type FormInput,
  type ValidationErrors,
  validateForm
} from "@/validator/formvalidator";

describe("validateForm", () => {
  test("正常な名前とメールアドレスならエラーがない", () => {
    // 1. 正常な name と email を持つ入力を用意してください。
    const input: FormInput = {
      name: " 鈴木花子 ",
      email: "suzuki@example.com"
    };
    // 2. validateForm を呼び出してください。
    const result = validateForm(input);
    // 3. 結果が空のオブジェクトになることを確認してください。
    const expected: ValidationErrors = {};
    expect(result).toEqual(expected);
  });

  test("名前が空なら名前のエラーを返す", () => {
    // 1. 空白だけの name と正常な email を用意してください。
    const input: FormInput = {
      name: "  ",
      email: "anonymous@example.com"
    };
    // 2. validateForm を呼び出してください。
    const result = validateForm(input);
    // 3. name に「名前を入力してください」が入っていることを確認してください。
    const expected: ValidationErrors = { name: "名前を入力してください"};
    expect(result).toEqual(expected);
  });

  test("名前が20文字を超えたら長さのエラーを返す", () => {
    // 1. 21文字以上の name と正常な email を用意してください。
    const input: FormInput = {
      name: "寿限無、寿限無、五劫の擦り切れ、海砂利水魚の、水行末 雲来末 風来末、食う寝る処に住む処、藪ら柑子のぶら柑子、パイポパイポ パイポのシューリンガン、シューリンガンのグーリンダイ、グーリンダイのポンポコピーのポンポコナーの、長久命の長助",
      email: "anonymous@example.com"
    };
    // 2. validateForm を呼び出してください。
    const result = validateForm(input);
    // 3. name に文字数制限のエラーが入っていることを確認してください。
    const expected: ValidationErrors = { name: "名前は20文字以内で入力してください"};
    expect(result).toEqual(expected);
  });

  test("メールアドレスに@がなければ形式エラーを返す", () => {
    // 1. 正常な name と、@を含まない email を用意してください。
    const input: FormInput = {
      name: "佐藤じゃり",
      email: "example.com"
    };
    // 2. validateForm を呼び出してください。
    const result = validateForm(input);
    // 3. email に形式エラーが入っていることを確認してください。
    const expected: ValidationErrors = { email: "メールアドレスの形式が正しくありません"};
    expect(result).toEqual(expected);

  });

  test("名前とメールの両方が不正なら両方のエラーを返す", () => {
    // 1. 空の name と空の email を用意してください。
    const input: FormInput = {
      name: "",
      email: ""
    };
    // 2. validateForm を呼び出してください。
    const result = validateForm(input);
    // 3. name と email の両方にエラーが入っていることを確認してください。
    const expected: ValidationErrors = {
      name: "名前を入力してください",
      email: "メールアドレスを入力してください"
    };
    expect(result).toEqual(expected);
  });
});
