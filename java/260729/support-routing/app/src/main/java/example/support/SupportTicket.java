package example.support;

import java.util.List;
import java.util.Objects;

public record SupportTicket(
    String ticketId,
    String customerName,
    String description,
    SupportIssue issue,
    List<String> assigneeCandidates
) {
    public SupportTicket {
        Objects.requireNonNull(
            ticketId,
            "ticketId must not be null"
        );
        Objects.requireNonNull(
            customerName,
            "cutomerName must not be null"
        );
        Objects.requireNonNull(
            description,
            "description must not be null"
        );
        Objects.requireNonNull(
            issue,
            "issue must not be null"
        );
        Objects.requireNonNull(
            assigneeCandidates,
            "assigneeCandidates must not be null"
        );

        assigneeCandidates = List.copyOf(assigneeCandidates);
    }
}
