package example.support;

public sealed interface RoutingDecision
    permits RoutingDecision.Escalated,
            RoutingDecision.Queued,
            RoutingDecision.Rejected {
    record Escalated(
        String ticketId,
        String assignee,
        String reason
    ) implements RoutingDecision {}

    record Queued(
        String ticketId,
        String assignee,
        String queueName
    ) implements RoutingDecision {}

    record Rejected(
        String ticketId,
        String reason
    ) implements RoutingDecision {}
}
