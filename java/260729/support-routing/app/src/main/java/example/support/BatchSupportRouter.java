package example.support;

import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.Executors;

public final class BatchSupportRouter {
    private final SupportRouter router;

    public BatchSupportRouter(
        SupportRouter router
    ) {
        this.router = router;
    }

    public List<RoutingDecision> routeAll(
        List<SupportTicket> tickets
    ) {
        try (
            var executor = Executors.newVirtualThreadPerTaskExecutor()
        ) {
            var tasks = tickets.stream().<Callable<RoutingDecision>>map(
                ticket -> () -> router.route(ticket)
            ).toList();

            return executor.invokeAll(tasks)
                .stream()
                .map(future -> {
                try {
    return future.get();
                } catch (Exception exception) {
                    throw new IllegalStateException(
                        "batch routing failed",
                        exception
                    );
                }
            }).toList();
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();

            throw new IllegalStateException(
                "batch routing was interrupted",
                exception
            );
        }
    }
}
