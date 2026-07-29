package example.support;

public record AccessRequest(
    String systemName,
    boolean managerApproved
) implements SupportIssue {}
