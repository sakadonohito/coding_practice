import { describe, expect, it } from "vitest";

import { allocateReservations } from "../src/allocator.js";
import {
  AllocationError,
  type ReservationRequest,
} from "../src/types.js";

function request(
  overrides: Partial<ReservationRequest> = {},
): ReservationRequest {
  return {
    id: "REQ-001",
    customerTier: "standard",
    requestedSeats: 1,
    submittedAt: "2026-08-06T09:00:00.000Z",
    ...overrides,
  };
}

describe("allocateReservations", () => {
  it("premiumをstandardより先に割り当てる", () => {
    const requests =[
      {
        id: "REQ-001",
        customerTier: "standard",
        requestedSeats: 2,
        submittedAt: "2026-08-06T09:00:00.000Z",
      },
      {
        id: "REQ-002",
        customerTier: "premium",
        requestedSeats: 2,
        submittedAt: "2026-08-06T10:00:00.000Z",
      },
    ] satisfies readonly ReservationRequest[];
    const checkRequest =[
      {
        id: "REQ-001",
        customerTier: "standard",
        requestedSeats: 2,
        submittedAt: "2026-08-06T09:00:00.000Z",
      },
      {
        id: "REQ-002",
        customerTier: "premium",
        requestedSeats: 2,
        submittedAt: "2026-08-06T10:00:00.000Z",
      },
    ] satisfies readonly ReservationRequest[];
    const report = allocateReservations(requests, 2);

    expect(report.decisions.map(d => d.requestId)).toEqual(["REQ-002", "REQ-001"]);
    expect(report.decisions.map(d => d.status)).toEqual(["confirmed", "waitlisted"]);
    expect(requests).toEqual(checkRequest);
    //オマケ："REQ-002"が2席confirmedになって"REQ-001"の2席がwaitlistedになっているのが既に分かっているがおまけで個別の検査をしてみた
    expect(report.decisions.filter(d => d.requestId === "REQ-001")[0].status).toEqual("waitlisted");
    expect(report.decisions.filter(d => d.requestId === "REQ-002")[0].status).toEqual("confirmed");
  });

  it("同じ顧客区分なら申請時刻の早い順にする", () => {
    const requests =[
      {
        id: "REQ-001",
        customerTier: "standard",
        requestedSeats: 2,
        submittedAt: "2026-08-06T10:00:00.000Z",
      },
      {
        id: "REQ-002",
        customerTier: "standard",
        requestedSeats: 2,
        submittedAt: "2026-08-06T08:00:00.000Z",
      },
      {
        id: "REQ-003",
        customerTier: "standard",
        requestedSeats: 2,
        submittedAt: "2026-08-06T09:00:00.000Z",
      },
    ] satisfies readonly ReservationRequest[];
    const report = allocateReservations(requests, 6);

    expect(report.decisions.map(d => d.requestId)).toEqual(["REQ-002", "REQ-003", "REQ-001"]);

  });

  it("残席不足では部分確保せず次の申請へ残す", () => {
    const requests =[
      {
        id: "REQ-001",
        customerTier: "standard",
        requestedSeats: 3,
        submittedAt: "2026-08-06T09:00:00.000Z",
      },
      {
        id: "REQ-002",
        customerTier: "standard",
        requestedSeats: 2,
        submittedAt: "2026-08-06T10:00:00.000Z",
      },
    ] satisfies readonly ReservationRequest[];
    const report = allocateReservations(requests, 2);

    expect(report.remainingSeats).toEqual(0);
    expect(report.confirmedSeatCount).toEqual(2);
    expect(report.decisions.filter(d => d.requestId === "REQ-001")[0].availableSeats).toEqual(2);
        expect(report.decisions.filter(d => d.requestId === "REQ-002")[0].allocatedSeats).toEqual(2);
  });

  it("空の申請一覧では定員をそのまま残す", () => {
    const report = allocateReservations([], 5);
    const expected = {
      decisions: [],
      initialCapacity: 5,
      confirmedRequestCount: 0,
      waitlistedRequestCount: 0,
      confirmedSeatCount: 0,
      remainingSeats: 5,
    }
    expect(report).toEqual(expected);
  });

  it("重複した申請IDを拒否する", () => {
    try {
      const requests =[
        {
          id: "REQ-001",
          customerTier: "standard",
          requestedSeats: 2,
          submittedAt: "2026-08-06T10:00:00.000Z",
        },
        {
          id: "REQ-002",
          customerTier: "standard",
          requestedSeats: 2,
          submittedAt: "2026-08-06T08:00:00.000Z",
        },
        {
          id: "REQ-001",
          customerTier: "standard",
          requestedSeats: 2,
          submittedAt: "2026-08-06T09:00:00.000Z",
        },
      ] satisfies readonly ReservationRequest[];
      allocateReservations(requests, 4);
      expect.fail("AllocationErrorが必要です。");
    } catch (error: unknown) {
      expect(error).toBeInstanceOf(AllocationError);

      if (!(error instanceof AllocationError)) {
        return;
      }
      expect(error.code).toBe("DUPLICATE_REQUEST_ID");
      expect(error.message).toBe(
        "duplicate request id: REQ-001"
      );
    }
  });

  it.each([
    {
      name: "負の定員",
      requests: [] as ReservationRequest[],
      capacity: -1,
      code: "INVALID_CAPACITY",
    },
    {
      name: "空白のID",
      requests: [request({ id: "   " })],
      capacity: 1,
      code: "BLANK_REQUEST_ID",
    },
    {
      name: "小数の要求席数",
      requests: [request({ requestedSeats: 1.5 })],
      capacity: 2,
      code: "INVALID_REQUESTED_SEATS",
    },
    {
      name: "不正な日時",
      requests: [request({ submittedAt: "invalid" })],
      capacity: 2,
      code: "INVALID_SUBMITTED_AT",
    },
  ] as const)(
    "不正な入力を拒否する: $name",
    ({ requests, capacity, code }) => {
      /*
       * allocateReservationsを実行する。
       * AllocationErrorを捕捉する。
       * error.codeがcodeと一致することを確認する。
       */
      try {
        const report = allocateReservations(requests, capacity);
        expect.fail("AllocationErrorが必要です。");
      } catch (error: unknown) {
        expect(error).toBeInstanceOf(AllocationError);

        if (!(error instanceof AllocationError)) {
          return;
        }

        expect(error.code).toBe(code);
      }

    },
  );
});
