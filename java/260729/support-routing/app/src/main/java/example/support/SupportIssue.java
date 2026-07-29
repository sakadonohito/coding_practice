package example.support;

public sealed interface SupportIssue
    permits Incident,
            AccessRequest,
            BillingQuestion {}
