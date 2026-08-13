export type CustomerTier = "standard" | "premium";

export type ReservationRequest = Readonly<{
  id: string;
  customerTier: CustomerTier;
  requestedSeats: number;
  submittedAt: string;
}>;

export type ConfirmedDecision = Readonly<{
  status: "confirmed";
  requestId: string;
  allocatedSeats: number;
  remainingSeats: number;
}>;

export type WaitlistedDecision = Readonly<{
  status: "waitlisted";
  requestId: string;
  requestedSeats: number;
  availableSeats: number;
}>;

export type AllocationDecision =
  | ConfirmedDecision
  | WaitlistedDecision;

export type AllocationReport = Readonly<{
  decisions: readonly AllocationDecision[];
  initialCapacity: number;
  confirmedRequestCount: number;
  waitlistedRequestCount: number;
  confirmedSeatCount: number;
  remainingSeats: number;
}>;

export type AllocationErrorCode =
  | "INVALID_CAPACITY"
  | "BLANK_REQUEST_ID"
  | "INVALID_REQUESTED_SEATS"
  | "INVALID_SUBMITTED_AT"
  | "DUPLICATE_REQUEST_ID";

export class AllocationError extends Error {
  constructor(
    public readonly code: AllocationErrorCode,
    message: string,
  ) {
    super(message);
    this.name = "AllocationError";
  }
}
