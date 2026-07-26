export type MessageFormState = {
  characterCount: number;
  isEmpty: boolean;
  isOverLimit: boolean;
  canSubmit: boolean;
  errorMessage: string | null;
};

export function createMessageFormState(
  message: string,
  maxLength: number,
): MessageFormState {
  const normalizedMessage = message.trim();
  const characterCount = message.length;

  const isEmpty = normalizedMessage.length === 0;
  const isOverLimit = characterCount > maxLength;

  let errorMessage: string | null = null;

  if (isOverLimit) {
    errorMessage = "文字数が上限を超えています";
  }

  return {
    characterCount,
    isEmpty,
    isOverLimit,
    canSubmit: !isEmpty && !isOverLimit,
    errorMessage,
  };
}

export function renderMessageFormState (
  state: MessageFormState,
  maxLength: number,
  countElement: HTMLElement,
  errorElement: HTMLElement,
  submitButton: HTMLButtonElement,
): void {
  countElement.textContent = `${state.characterCount} / ${maxLength}`;

  submitButton.disabled = !state.canSubmit;

  if (state.errorMessage === null) {
    errorElement.textContent = "";
    errorElement.hidden = true;
    return;
  }

  errorElement.textContent = state.errorMessage;
  errorElement.hidden = false;
}
