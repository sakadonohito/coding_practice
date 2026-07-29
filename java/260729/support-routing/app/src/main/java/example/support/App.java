package example.support;

import java.util.List;

public final class App {

    private App() {
    }

    public static void main(String[] args) {
        var ticket = new SupportTicket(
                "TICKET-001",
                "山田太郎",
                "本番サービスへ接続できません",
                new Incident(
                        "注文API",
                        Severity.CRITICAL,
                        true
                ),
                List.of(
                        "佐藤",
                        "鈴木",
                        "田中"
                )
        );

        var router = new SupportRouter();
        var decision = router.route(ticket);

        System.out.println(decision);
    }
}
