import {
  createMessageFormState,
  renderMessageFormState
} from "@/components/message-form";

const MAX_MESSAGE_LENGTH = 100;
const messageInput = document.querySelector<HTMLTextAreaElement>("#message");
const countElement = document.querySelector<HTMLElement>("#character-count");
const errorElement = document.querySelector<HTMLElement>("#error-message");
const submitButton = document.querySelector<HTMLButtonElement>("button");

if (
  messageInput === null ||
    countElement === null ||
    errorElement === null ||
    submitButton === null
) {
  throw new Error("フォームの必要なHTML要素が見つかりません");
}

function updateForm(): void {
  const state = createMessageFormState(
    messageInput?.value,
    MAX_MESSAGE_LENGTH,
  );

  renderMessageFormState(
    state,
    MAX_MESSAGE_LENGTH,
    countElement,
    errorElement,
    submitButton,
  );
}

messageInput.addEventListener("input", updateForm);

updateForm();
