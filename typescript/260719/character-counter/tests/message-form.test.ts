import {
  beforeEach,
  describe,
  expect,
  it,
} from "vitest";

import {
  type MessageFormState,
  createMessageFormState,
  renderMessageFormState
} from "@/components/message-form";

describe("createMessageFormState", () => {
  it("空文字列では送信できない", () => {
    // 空文字列と最大文字数100を渡してください。
    const result = createMessageFormState("", 100);
    // characterCountが0になることを確認してください。
    expect(result.characterCount).toBe(0);
    // isEmptyがtrueになることを確認してください。
    expect(result.isEmpty).toBeTruthy();
    expect(result.isEmpty).toBe(true);
    // canSubmitがfalseになることを確認してください。
    expect(result.canSubmit).toBeFalsy();
        expect(result.canSubmit).toBe(false);
  });

  it("空白だけの文字列では送信できない", () => {
    // 半角スペースだけの文字列を渡してください。
    const result = createMessageFormState("     ", 100);
    // isEmptyがtrueになることを確認してください。
    expect(result.isEmpty).toBeTruthy();
    expect(result.isEmpty).toBe(true);
    // canSubmitがfalseになることを確認してください。
    expect(result.canSubmit).toBeFalsy();
    expect(result.canSubmit).toBe(false);
  });

  it("上限以内の文字列なら送信できる", () => {
    // "こんにちは"と最大文字数100を渡してください。
    const result = createMessageFormState("こんにちは", 100);
    // characterCountが5になることを確認してください。
    expect(result.characterCount).toBe(5);
    // isOverLimitがfalseになることを確認してください。
    expect(result.isOverLimit).toBeFalsy();
    expect(result.isOverLimit).toBe(false);
    // canSubmitがtrueになることを確認してください。
    expect(result.canSubmit).toBeTruthy();
    expect(result.canSubmit).toBe(true);
    // errorMessageがnullになることを確認してください。
    expect(result.errorMessage).toBeNull();
    expect(result.errorMessage).toBe(null);
  });

  it("上限を超えた文字列では送信できない", () => {
    // 101文字の文字列と最大文字数100を渡してください。
    const dummyText = "ぽ".repeat(101);
    const result = createMessageFormState(dummyText, 100);
    // isOverLimitがtrueになることを確認してください。
    expect(result.isOverLimit).toBeTruthy();
    expect(result.isOverLimit).toBe(true);
    // canSubmitがfalseになることを確認してください。
    expect(result.canSubmit).toBeFalsy();
    expect(result.canSubmit).toBe(false);
    // errorMessageが
    // "文字数が上限を超えています"
    // になることを確認してください。
    expect(result.errorMessage).toBe("文字数が上限を超えています");
  });

  it("上限ちょうどの文字列なら送信できる", () => {
    // 100文字の文字列と最大文字数100を渡してください。
    const dummyText = "ぬ".repeat(100);
    const result = createMessageFormState(dummyText, 100);
    // characterCountが100になることを確認してください。
    expect(result.characterCount).toBe(100);
    // isOverLimitがfalseになることを確認してください。
    expect(result.isOverLimit).toBeFalsy();
    expect(result.isOverLimit).toBe(false);
    // canSubmitがtrueになることを確認してください。
    expect(result.canSubmit).toBeTruthy();
    expect(result.canSubmit).toBe(true);
  });
});

describe("renderMessageFormState", () => {
  let countElement: HTMLParagraphElement;
  let errorElement: HTMLParagraphElement;
  let submitButton: HTMLButtonElement;

  beforeEach(() => {
    document.body.innerHTML = `
      <p id="character-count"></p>
      <p id="error-message"></p>
      <button id="submit-button"></button>
    `;

    countElement =
      document.querySelector<HTMLParagraphElement>(
        "#character-count",
      )!;

    errorElement =
      document.querySelector<HTMLParagraphElement>(
        "#error-message",
      )!;

    submitButton =
      document.querySelector<HTMLButtonElement>(
        "#submit-button",
      )!;
  });

  it("文字数と最大文字数を画面へ表示する", () => {
    // characterCountが20の状態を用意してください。
    const state: MessageFormState = {
      characterCount: 20,
      isEmpty: false,
      isOverLimit: false,
      canSubmit: true,
      errorMessage: null,
    };
    // renderMessageFormStateを呼び出してください。
    renderMessageFormState(
      state,
      100,
      countElement,
      errorElement,
      submitButton,
    );
    // countElement.textContentが"20 / 100"になることを確認してください。
    expect(countElement.textContent).toBe("20 / 100");
  });

  it("送信可能ならボタンを有効にする", () => {
    // canSubmitがtrueの状態を用意してください。
    const state: MessageFormState = {
      characterCount: 20,
      isEmpty: false,
      isOverLimit: false,
      canSubmit: true,
      errorMessage: null,
    };
    // renderMessageFormStateを呼び出してください。
    renderMessageFormState(
      state,
      100,
      countElement,
      errorElement,
      submitButton,
    );
    // submitButton.disabledがfalseになることを確認してください。
    expect(submitButton.disabled).toBeFalsy();
    expect(submitButton.disabled).toBe(false);
  });

  it("エラーがある場合はメッセージを表示する", () => {
    // errorMessageに
    // "文字数が上限を超えています"
    // を持つ状態を用意してください。
    const state: MessageFormState = {
      characterCount: 101,
      isEmpty: false,
      isOverLimit: true,
      canSubmit: false,
      errorMessage: "文字数が上限を超えています",
    };
    // renderMessageFormStateを呼び出してください。
    renderMessageFormState(
      state,
      100,
      countElement,
      errorElement,
      submitButton,
    );
    // errorElement.textContentがエラーメッセージになることを確認してください。
    expect(errorElement.textContent).toBe("文字数が上限を超えています");
    // errorElement.hiddenがfalseになることを確認してください。
    expect(errorElement.hidden).toBeFalsy();
    expect(errorElement.hidden).toBe(false);
  });

  it("エラーがない場合はエラー要素を非表示にする", () => {
    // errorMessageがnullの状態を用意してください。
    const state: MessageFormState = {
      characterCount: 10,
      isEmpty: false,
      isOverLimit: false,
      canSubmit: true,
      errorMessage: null,
    };
    // renderMessageFormStateを呼び出してください。
    renderMessageFormState(
      state,
      100,
      countElement,
      errorElement,
      submitButton,
    );
    // errorElement.textContentが空文字列になることを確認してください。
    expect(errorElement.textContent).toBe("");
    // errorElement.hiddenがtrueになることを確認してください。
    expect(errorElement.hidden).toBeTruthy();
    expect(errorElement.hidden).toBe(true);
  });
});
