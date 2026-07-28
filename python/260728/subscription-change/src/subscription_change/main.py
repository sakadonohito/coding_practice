from datetime import UTC, datetime

from subscription_change.models import (
    Plan,
    PlanChangeRequest,
    Subscription,
    SubscriptionStatus,
)
from subscription_change.service import evaluate_plan_change


def main() -> None:
    subscription = Subscription(
        customer_id="CUSTOMER-001",
        current_plan=Plan.STANDARD,
        status=SubscriptionStatus.ACTIVE,
        period_started_at=datetime(
            2026,
            7,
            1,
            tzinfo=UTC,
        ),
        renews_at=datetime(
            2026,
            7,
            31,
            tzinfo=UTC,
        ),
    )

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.PREMIUM,
        requested_at=datetime(
            2026,
            7,
            16,
            tzinfo=UTC,
        ),
    )

    decision = evaluate_plan_change(request)

    print(f"判定: {decision.timing}")
    print(f"現在プラン: {decision.current_plan}")
    print(f"申請プラン: {decision.requested_plan}")
    print(f"適用日時: {decision.effective_at}")
    print(f"追加料金: {decision.additional_charge}円")


if __name__ == "__main__":
    main()
