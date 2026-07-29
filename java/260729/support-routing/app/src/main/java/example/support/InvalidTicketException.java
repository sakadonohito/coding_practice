package example.support;

public final class InvalidTicketException extends IllegalArgumentException {
    public InvalidTicketException(
        String message
    ) {
        super(message);
    }
}
