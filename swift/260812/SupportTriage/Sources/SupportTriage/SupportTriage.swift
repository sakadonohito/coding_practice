// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public enum CustomerPlan: Equatable, Sendable {
    case standard
    case premium
}

public enum TicketCategory: Equatable, Sendable {
    case question
    case defect
    case serviceUnavailable
}

public struct SupportTicket: Equatable, Sendable {
    public let id: String
    public let customerPlan: CustomerPlan
    public let category: TicketCategory
    public let waitingMinutes: Int

    public init(
        id: String,
        customerPlan: CustomerPlan,
        category: TicketCategory,
        waitingMinutes: Int
    ) {
        self.id = id
        self.customerPlan = customerPlan
        self.category = category
        self.waitingMinutes = waitingMinutes
    }
}

public enum PriorityReason: Equatable, Sendable {
    case serviceUnavailable
    case premiumDefect
    case longWaiting(minutes: Int)
}

public enum TicketPriority: Equatable, Sendable {
    case normal
    case high(reason: PriorityReason)
    case urgent(reason: PriorityReason)
}

public enum SupportQueue: String, CaseIterable, Equatable, Hashable, Sendable {
    case general
    case technical
    case incident
}

public struct TicketDecision: Equatable, Sendable {
    public let ticketID: String
    public let priority: TicketPriority
    public let queue: SupportQueue
}

public struct TriageReport: Equatable, Sendable {
    public let decisions: [TicketDecision]
    public let queueCounts: [SupportQueue: Int]
    public let normalCount: Int
    public let highCount: Int
    public let urgentCount: Int
}

public enum TicketError: Error, Equatable, Sendable {
    case blankID(index: Int)
    case negativeWaitingMinutes(ticketID: String, value: Int)
    case duplicateID(String)
}

private func validate(_ tickets: [SupportTicket]) throws {
    var seenIDs = Set<String>()
    for (index, ticket) in tickets.enumerated() {
        guard !ticket.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TicketError.blankID(index: index)
        }
        guard ticket.waitingMinutes >= 0 else {
            throw TicketError.negativeWaitingMinutes(ticketID: ticket.id, value: ticket.waitingMinutes)
        }
        let result = seenIDs.insert(ticket.id)
        guard result.inserted else {
            throw TicketError.duplicateID(ticket.id)
        }
    }
}

public func determinePriority(
    for ticket: SupportTicket
) -> TicketPriority {
    switch (ticket.category, ticket.customerPlan, ticket.waitingMinutes) {
    case (.serviceUnavailable, _, _):
        return .urgent(reason: .serviceUnavailable)
    case (.defect, .premium, _):
        return .high(reason: .premiumDefect)
    case (_, _, let minutes) where minutes >= 120:
        return .high(reason: .longWaiting(minutes: ticket.waitingMinutes))
    default:
        return .normal
    }
}

public func determineQueue(
    for category: TicketCategory
) -> SupportQueue {
    switch category {
    case .question:
        return .general
    case .defect:
        return .technical
    case .serviceUnavailable:
        return .incident
    }
}

private struct ReportAccumulator {
    var queueCounts: [SupportQueue: Int]
    var normalCount = 0
    var highCount = 0
    var urgentCount = 0
}

public func triage(
    _ tickets: [SupportTicket]
) throws -> TriageReport {
    try validate(tickets)
    let decisions = tickets.map { ticket in
        TicketDecision(
          ticketID: ticket.id,
          priority: determinePriority(for: ticket),
          queue: determineQueue(for: ticket.category)
        )
    }
    let initialQueueCounts = Dictionary(
      uniqueKeysWithValues: SupportQueue.allCases.map { queue in (queue, 0) }
    )
    let initialAccumulator = ReportAccumulator(queueCounts: initialQueueCounts)
    let reportData = decisions.reduce(into: initialAccumulator) { accumulator, decision in
        accumulator.queueCounts[decision.queue, default: 0] += 1

        switch decision.priority {
        case .normal:
            accumulator.normalCount += 1
        case .high:
            accumulator.highCount += 1
        case .urgent:
            accumulator.urgentCount += 1
        }
    }

    return TriageReport(
      decisions: decisions,
      queueCounts: reportData.queueCounts,
      normalCount: reportData.normalCount,
      highCount: reportData.highCount,
      urgentCount: reportData.urgentCount
    )
}
