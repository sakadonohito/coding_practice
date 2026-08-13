//import { request } from "node:https";
import {
  AllocationError,
  type AllocationDecision,
  type AllocationReport,
  type ReservationRequest,
} from "./types.js";

type IndexedRequest = Readonly<{
  request: ReservationRequest;
  originalIndex: number;
}>;

function validateInputs(
  requests: readonly ReservationRequest[],
  capacity: number,
): void {
  if (!(Number.isInteger(capacity) && capacity >= 0)) {
    throw new AllocationError(
      "INVALID_CAPACITY",
      `capacity must be a non-negative integer: ${capacity}`,
    );
  }
  const ids = new Set<string>();
  for (const [index,request] of requests.entries()) {
    if (request.id.trim() === '') {
      throw new AllocationError(
        "BLANK_REQUEST_ID",
        `request id must not be blank at index ${index}`,
      );
    }
    if (!(Number.isInteger(request.requestedSeats) && request.requestedSeats >= 1)) {
      throw new AllocationError(
        "INVALID_REQUESTED_SEATS",
        `requestedSeats must be a positive integer: ${request.id} = ${request.requestedSeats}`,
      );
    }
    if (Number.isNaN(Date.parse(request.submittedAt))) {
      throw new AllocationError(
        "INVALID_SUBMITTED_AT",
        `submittedAt must be a valid date: ${request.id} = ${request.submittedAt}`,
      );
    }
    if (ids.has(request.id)) {
      throw new AllocationError(
        "DUPLICATE_REQUEST_ID",
        `duplicate request id: ${request.id}`,
      );
    } else {
      ids.add(request.id);
    }
  }
}

function tierPriority(
  request: ReservationRequest,
): number {
  return (request.customerTier === 'premium') ? 0 : 1;
}

function compareRequests(
  left: IndexedRequest,
  right: IndexedRequest,
): number {
  const tierDiff = tierPriority(left.request) - tierPriority(right.request);
  if (tierDiff !== 0) {
    return tierDiff;
  }
  const dateDiff = Date.parse(left.request.submittedAt) - Date.parse(right.request.submittedAt);
  if (dateDiff !== 0) {
    return dateDiff;
  }
  return left.originalIndex - right.originalIndex;
}

export function allocateReservations(
  requests: readonly ReservationRequest[],
  capacity: number,
): AllocationReport {
  validateInputs(requests, capacity);
  const compareList = requests.map( (request, index) => {
    return {
      request,
      originalIndex: index,
    };
  });
  const sorted = compareList.toSorted(compareRequests);
  let remaining = capacity;
  const decisions: AllocationDecision[] = [];
  for (const item of sorted) {
    const req = item.request;
    if (req.requestedSeats <= remaining) {
      remaining -= req.requestedSeats;
      decisions.push({
        status: "confirmed",
        requestId: req.id,
        allocatedSeats: req.requestedSeats,
        remainingSeats: remaining,
      });
    } else {
      decisions.push({
        status: "waitlisted",
        requestId: req.id,
        requestedSeats: req.requestedSeats,
        availableSeats: remaining,
      });
    }
  }
  const confirmed = decisions.filter(d => d.status === "confirmed").length;
  const waitlisted = decisions.filter(d => d.status === "waitlisted").length;
  const confirmedSeatCount = capacity - remaining;
  return {
    decisions: decisions,
    initialCapacity: capacity,
    confirmedRequestCount: confirmed,
    waitlistedRequestCount: waitlisted,
    confirmedSeatCount: confirmedSeatCount,
    remainingSeats: remaining,
  };
}
