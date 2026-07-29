package example.support;

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;
import java.util.stream.Stream;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Named;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

final class SupportRouterTest {

    private final SupportRouter router =
            new SupportRouter();

    @Test
    @DisplayName(
            "重大障害を最後の担当者へエスカレーションする"
    )
    void criticalOutageIsEscalated() {
        /*
         * 要件:
         *
         * ticketId:
         * "TICKET-001"
         *
         * customerName:
         * "山田太郎"
         *
         * issue:
         * new Incident(
         *     "注文API",
         *     Severity.CRITICAL,
         *     true
         * )
         *
         * assigneeCandidates:
         * ["佐藤", "鈴木", "田中"]
         *
         * router.route()を実行する。
         *
         * 結果が次と等しいことを確認する。
         *
         * new RoutingDecision.Escalated(
         *     "TICKET-001",
         *     "田中",
         *     "critical outage: 注文API"
         * )
         */
        var ticket = new SupportTicket(
            "TICKET-001",
            "山田太郎",
            "本番サービスへ接続できません",
            new Incident(
                "注文API",
                Severity.CRITICAL,
                true
            ),
            List.of("佐藤", "鈴木", "田中")
        );
        var actual = router.route(ticket);
        var expected = new RoutingDecision.Escalated(
            "TICKET-001",
            "田中",
            "critical outage: 注文API"
        );

        assertEquals(expected, actual);
    }

    @Test
    @DisplayName(
            "通常の障害を先頭担当者のキューへ入れる"
    )
    void ordinaryIncidentIsQueued() {
        /*
         * 要件:
         *
         * severity:
         * Severity.MEDIUM
         *
         * serviceUnavailable:
         * false
         *
         * 担当候補者:
         * ["佐藤", "鈴木"]
         *
         * 結果がRoutingDecision.Queuedである。
         *
         * assignee:
         * "佐藤"
         *
         * queueName:
         * "incident"
         */
        var ticket = new SupportTicket(
            "TICKET-001",
            "山田太郎",
            "テスト環境へ接続できません",
            new Incident(
                "注文API",
                Severity.MEDIUM,
                false
            ),
            List.of("佐藤", "鈴木")
        );
        var actual = router.route(ticket);
        var expected = new RoutingDecision.Queued(
            "TICKET-001",
            "佐藤",
            "incident"
        );

        assertEquals(expected, actual);
    }

    @Test
    @DisplayName(
            "承認済みアクセス申請を通常キューへ入れる"
    )
    void approvedAccessRequestIsQueued() {
        /*
         * 要件:
         *
         * issue:
         * new AccessRequest(
         *     "会計システム",
         *     true
         * )
         *
         * 結果が次と等しいことを確認する。
         *
         * new RoutingDecision.Queued(
         *     "TICKET-003",
         *     "佐藤",
         *     "access-request"
         * )
         */
        var ticket = new SupportTicket(
            "TICKET-003",
            "山田太郎",
            "テスト環境へ接続できません",
            new AccessRequest(
                "会計システム",
                true
            ),
            List.of("佐藤", "鈴木")
        );
        var actual = router.route(ticket);
        var expected = new RoutingDecision.Queued(
            "TICKET-003",
            "佐藤",
            "access-request"
        );

        assertEquals(expected, actual);
    }

    @Test
    @DisplayName(
            "未承認アクセス申請を拒否する"
    )
    void unapprovedAccessRequestIsRejected() {
        /*
         * 要件:
         *
         * issue:
         * new AccessRequest(
         *     "会計システム",
         *     false
         * )
         *
         * 結果が次と等しいことを確認する。
         *
         * new RoutingDecision.Rejected(
         *     "TICKET-004",
         *     "manager approval is required: 会計システム"
         * )
         */
        var ticket = new SupportTicket(
            "TICKET-004",
            "山田太郎",
            "テスト環境へ接続できません",
            new AccessRequest(
                "会計システム",
                false
            ),
            List.of("佐藤", "鈴木")
        );
        var actual = router.route(ticket);
        var expected = new RoutingDecision.Rejected(
            "TICKET-004",
            "manager approval is required: 会計システム"
        );

        assertEquals(expected, actual);
    }

    @Test
    @DisplayName(
            "10万円以上の請求問題をエスカレーションする"
    )
    void largeBillingQuestionIsEscalated() {
        /*
         * 要件:
         *
         * invoiceNumber:
         * "INV-001"
         *
         * disputedAmount:
         * 100_000L
         *
         * 担当候補者:
         * ["佐藤", "鈴木", "田中"]
         *
         * 結果の担当者が
         * 最後の"田中"であることを確認する。
         */
        var ticket = new SupportTicket(
            "TICKET-005",
            "山田太郎",
            "姉さん、事件です",
            new BillingQuestion(
                "INV-001",
                100_000L
            ),
            List.of("佐藤", "鈴木", "田中")
        );
        var actual = router.route(ticket);
        var expected = new RoutingDecision.Escalated(
            "TICKET-005",
            "田中",
            "large billing dispute: INV-001"
        );

        assertEquals(expected, actual);
    }

    @Test
    @DisplayName(
            "担当候補者が空なら例外になる"
    )
    void emptyAssigneeCandidatesAreRejected() {
        /*
         * 要件:
         *
         * assigneeCandidatesに
         * List.of()を指定する。
         *
         * router.route()を実行すると、
         * InvalidTicketExceptionが発生する。
         *
         * 例外メッセージ:
         * "at least one assignee is required"
         */
        var ticket = new SupportTicket(
            "TICKET-006",
            "山田太郎",
            "テスト環境へ接続できません",
            new Incident(
                "注文API",
                Severity.MEDIUM,
                false
            ),
            List.of()
        );
        var exception = assertThrows(
            InvalidTicketException.class,
            () -> router.route(ticket)
        );
        assertEquals(
            "at least one assignee is required",
            exception.getMessage()
        );
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("routingCases")
    @DisplayName(
            "複数の問い合わせ種別を振り分ける"
    )
    void routesMultipleIssueTypes(
            String caseName,
            SupportIssue issue,
            Class<? extends RoutingDecision>
                    expectedType
    ) {
        /*
         * 要件:
         *
         * MethodSourceから次を受け取る。
         *
         * caseName
         * issue
         * expectedType
         *
         * 共通のSupportTicketを生成する。
         *
         * router.route()を実行する。
         *
         * 結果がexpectedTypeのインスタンスで
         * あることを確認する。
         *
         * assertInstanceOf()を使用する。
         */
        var ticket = new SupportTicket(
            "TICKET-PARAM",
            "テスト太郎",
            "テスト用問い合わせ",
            issue,
            List.of("佐藤", "鈴木", "斎藤")
        );

        var actual = router.route(ticket);
        assertInstanceOf(expectedType, actual);
    }

    static Stream<Arguments> routingCases() {
        return Stream.of(
                Arguments.of(
                        Named.of(
                                "通常障害",
                                "通常障害"
                        ),
                        new Incident(
                                "検索API",
                                Severity.LOW,
                                false
                        ),
                        RoutingDecision.Queued.class
                ),
                Arguments.of(
                        Named.of(
                                "重大障害",
                                "重大障害"
                        ),
                        new Incident(
                                "決済API",
                                Severity.CRITICAL,
                                true
                        ),
                        RoutingDecision.Escalated.class
                ),
                Arguments.of(
                        Named.of(
                                "未承認アクセス申請",
                                "未承認アクセス申請"
                        ),
                        new AccessRequest(
                                "管理画面",
                                false
                        ),
                        RoutingDecision.Rejected.class
                ),
                Arguments.of(
                        Named.of(
                                "高額請求問題",
                                "高額請求問題"
                        ),
                        new BillingQuestion(
                                "INV-999",
                                250_000L
                        ),
                        RoutingDecision.Escalated.class
                )
        );
    }
}
