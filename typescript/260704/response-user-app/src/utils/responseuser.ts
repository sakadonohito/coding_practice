export type User = {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
};

export type UserResponse = {
  id: number;
  displayName: string;
  status: "active" | "inactive";
};

export function toUserResponses(users: User[]): UserResponse[] {
  return users.map((user) => {
    return {
      id: user.id,
      displayName: user.name,
      status: user.isActive ? "active": "inactive",
    };
  });
};
