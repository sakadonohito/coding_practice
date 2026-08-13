import { allocateReservations } from "./allocator.js";
import type { ReservationRequest } from "./types.js";

const requests = [
  {
    id: "REQ-001",
    customerTier: "standard",
    requestedSeats: 2,
    submittedAt: "2026-08-06T09:00:00.000Z",
  },
  {
    id: "REQ-002",
    customerTier: "premium",
    requestedSeats: 3,
    submittedAt: "2026-08-06T09:30:00.000Z",
  },
  {
    id: "REQ-003",
    customerTier: "premium",
    requestedSeats: 2,
    submittedAt: "2026-08-06T09:00:00.000Z",
  },
] satisfies readonly ReservationRequest[];

const report = allocateReservations(requests, 5);

console.log(JSON.stringify(report, null, 2));
