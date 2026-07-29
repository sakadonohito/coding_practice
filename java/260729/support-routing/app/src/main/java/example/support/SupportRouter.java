package example.support;

public final class SupportRouter {
    private static final long
        LARGE_BILLING_AMOUNT = 100_000L;

    public RoutingDecision route(
        SupportTicket ticket
    ) {
        validate(ticket);

        return switch (ticket.issue()) {
            case Incident(
                var serviceName,
                var severity,
                var serviceUnavailable
            ) when severity == Severity.CRITICAL
                   && serviceUnavailable ->
                       new RoutingDecision.Escalated(
                           ticket.ticketId(),
                           ticket.assigneeCandidates()
                               .getLast(),
                           "critical outage: " + serviceName
                       );

            case Incident(
                var serviceName,
                var severity,
                var serviceUnavailable
            ) -> new RoutingDecision.Queued(
                ticket.ticketId(),
                ticket.assigneeCandidates().getFirst(),
                "incident"
            );

            case AccessRequest(
                var systemName,
                var managerApproved
            ) when managerApproved -> new RoutingDecision.Queued(
                ticket.ticketId(),
                ticket.assigneeCandidates().getFirst(),
                "access-request"
            );

            case AccessRequest(
                var systemName,
                var managerApproved
            ) -> new RoutingDecision.Rejected(
                ticket.ticketId(),
                "manager approval is required: " + systemName
            );

            case BillingQuestion(
                var invoiceNumber,
                var disputedAmount
            ) when disputedAmount >= LARGE_BILLING_AMOUNT ->
                new RoutingDecision.Escalated(
                    ticket.ticketId(),
                    ticket.assigneeCandidates().getLast(),
                    "large billing dispute: " + invoiceNumber
                );

            case BillingQuestion(
                var invoiceNumber,
                var disputedAmount
            ) -> new RoutingDecision.Queued(
                ticket.ticketId(),
                ticket.assigneeCandidates().getFirst(),
                "billing"
            );
        };
    }

    private void validate(
        SupportTicket ticket
    ) {
        if (ticket.ticketId().isBlank()) {
            throw new InvalidTicketException(
                "ticketId must not be blank"
            );
        }

        if (ticket.customerName().isBlank()) {
            throw new InvalidTicketException(
                "cutomerName must not be blank"
            );
        }

        if (ticket.description().isBlank()) {
            throw new InvalidTicketException(
                "description must not be blank"
            );
        }

        if (ticket.assigneeCandidates().isEmpty()) {
            throw new InvalidTicketException(
                "at least one assignee is required"
            );
        }

        if (ticket.assigneeCandidates().stream().anyMatch(String::isBlank)) {
            throw new InvalidTicketException(
                "assignee must not be blank"
            );
        }
    }
}
