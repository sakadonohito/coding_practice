package example.support;

public record Incident(
    String serviceName,
    Severity severity,
    boolean serviceUnavailable
) implements SupportIssue {}
