import {
  type FormInput,
  validateForm,
  displayValidationResult
} from "@/validator/formvalidator";

const input: FormInput = {
  name: " 山田太郎 ",
  email: "yamada@example.com"
};

const errors = validateForm(input);
const result = displayValidationResult(errors);
