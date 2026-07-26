import { toUserResponses, type User, type UserResponse } from "./utils/responseuser";

const users: User[] = [
  { id: 1, name: "Alice", email: "alice@example.com", isActive: true },
  { id: 2, name: "Bob", email: "bob@example.com", isActive: false },
];

console.log("=== result ===")
console.log(toUserResponses(users));
console.log("=== result ===")
