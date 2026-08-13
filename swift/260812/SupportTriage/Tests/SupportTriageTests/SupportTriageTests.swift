import Testing
@testable import SupportTriage

private func ticket(
    id: String = "T-001",
    plan: CustomerPlan = .standard,
    category: TicketCategory = .question,
    waitingMinutes: Int = 0
) -> SupportTicket {
    SupportTicket(
        id: id,
        customerPlan: plan,
        category: category,
        waitingMinutes: waitingMinutes
    )
}

@Test("サービス停止は最優先でurgentにする")
func serviceUnavailableIsUrgent() {
    let t = ticket(
      plan: .premium,
      category: .serviceUnavailable,
      waitingMinutes: 180
    )
    let priority = determinePriority(for: t)
    #expect(priority == .urgent(reason: .serviceUnavailable))
}

@Test("premiumの不具合はhighにする")
func premiumDefectIsHigh() {
    let t = ticket(
      plan: .premium,
      category: .defect,
      waitingMinutes: 10
    )
    let priority = determinePriority(for: t)
    #expect(priority == .high(reason: .premiumDefect))
}

@Test(
    "待ち時間の境界を判定する",
    arguments: [
        (119, TicketPriority.normal),
        (120, TicketPriority.high(reason: .longWaiting(minutes: 120)))
    ]
)
func waitingBoundary(
    minutes: Int,
    expected: TicketPriority
) {
    let t = ticket(plan: .standard, category: .question, waitingMinutes: minutes)
    #expect(determinePriority(for: t) == expected)
}

@Test("キューと優先度を入力順で集計する")
func triageBuildsReport() throws {
    let inputTickets = [
      ticket(id: "T-001", plan: .standard, category: .question, waitingMinutes: 0),
      ticket(id: "T-002", plan: .premium, category: .defect, waitingMinutes: 10),
      ticket(id: "T-003", plan: .standard, category: .serviceUnavailable, waitingMinutes: 5),
      ticket(id: "T-004", plan: .standard, category: .question, waitingMinutes: 180)
    ]
    let report = try triage(inputTickets)
    #expect(report.decisions.map(\.ticketID) == ["T-001","T-002","T-003","T-004"])
    #expect(report.queueCounts[.general] == 2)
    #expect(report.queueCounts[.technical] == 1)
    #expect(report.queueCounts[.incident] == 1)
    #expect(report.normalCount == 1)
    #expect(report.highCount == 2)
    #expect(report.urgentCount == 1)
}

@Test("空listでは全queueを0件で返す")
func emptyTicketsReturnZeroReport() throws {
    let report = try triage([])
    #expect(report.decisions.isEmpty)
    #expect(report.queueCounts[.general] == 0)
    #expect(report.queueCounts[.technical] == 0)
    #expect(report.queueCounts[.incident] == 0)
    #expect(report.queueCounts.count == 3)
    #expect(report.normalCount == 0)
    #expect(report.highCount == 0)
    #expect(report.urgentCount == 0)
}

@Test(
    "不正な入力をthrowする",
    arguments: [
        (
            [ticket(id: "   ")],
            TicketError.blankID(index: 0)
        ),
        (
            [ticket(id: "T-001", waitingMinutes: -1)],
            TicketError.negativeWaitingMinutes(
                ticketID: "T-001",
                value: -1
            )
        ),
        (
            [ticket(id: "T-001"), ticket(id: "T-001")],
            TicketError.duplicateID("T-001")
        )
    ]
)
func invalidInputThrows(
    tickets: [SupportTicket],
    expected: TicketError
) {
    do {
        _ = try triage(tickets)
        Issue.record("TicketErrorがスローされるはずですが、成功してしまいました")
    } catch let error as TicketError {
        #expect(error == expected)
    } catch {
        Issue.record("想定外のエラーがスローされました: \(error)")
    }
}
