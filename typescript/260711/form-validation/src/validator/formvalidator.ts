export type FormInput = {
  name: string;
  email: string;
};

export type ValidationErrors = {
  name?: string;
  email?: string;
};

export function validateForm(input: FormInput): ValidationErrors {
  const errors: ValidationErrors = {};

  const name = input.name.trim();
  const email = input.email.trim();

  if (name.length === 0) {
    errors.name = "名前を入力してください";
  } else if (name.length > 20) {
    errors.name = "名前は20文字以内で入力してください";
  }

  if (email.length === 0) {
    errors.email = "メールアドレスを入力してください";
  } else if (!email.includes("@")) {
    errors.email = "メールアドレスの形式が正しくありません";
  }

  return errors;
}

export function displayValidationResult(errors: ValidationErrors): void {
  const resultElement = document.querySelector<HTMLDivElement>("#result");

  if (resultElement === null) {
    return;
  }

  const messages: string[] = [];

  if (errors.name !== undefined) {
    messages.push(errors.name);
  }

  if (errors.email !== undefined) {
    messages.push(errors.email);
  }

  if (messages.length === 0) {
    resultElement.textContent = "入力内容に問題はありません";
    return;
  }

  resultElement.textContent = messages.join(" / ");
}
