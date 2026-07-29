package example.support;

public record BillingQuestion(
    String invoiceNumber,
    long disputedAmount
) implements SupportIssue {}
