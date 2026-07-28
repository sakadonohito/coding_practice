from datetime import UTC, datetime
from decimal import Decimal

import pytest

from subscription_change.models import (
    ChangeTiming,
    Plan,
    PlanChangeRequest,
    Subscription,
    SubscriptionStatus,
)
from subscription_change.service import (
    InvalidSubscriptionError,
    evaluate_plan_change,
)

# ========================================================
# ★ ここに補助関数を配置する！
# ========================================================
def create_subscription(
    *,
    current_plan: Plan = Plan.STANDARD,
    status: SubscriptionStatus = SubscriptionStatus.ACTIVE,
) -> Subscription:
    return Subscription(
        customer_id="CUSTOMER-001",
        current_plan=current_plan,
        status=status,
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


def test_upgrade_is_applied_immediately() -> None:
    """
    要件:
    現在プラン:
    Plan.STANDARD
    申請プラン:
    Plan.PREMIUM
    契約開始:
    2026-07-01 00:00 UTC
    次回更新:
    2026-07-31 00:00 UTC
    申請日時:
    2026-07-16 00:00 UTC
    契約期間は30日、残り期間は15日。
    月額差額:
    1,980 - 980 = 1,000円
    日割り追加料金:
    1,000 × 15 ÷ 30 = 500円
    結果について次を確認する。
    timing:
    ChangeTiming.IMMEDIATE
    effective_at:
    申請日時
    additional_charge:
    Decimal("500")
    """
    # subscription = Subscription(
    #     customer_id="CUSTOMER-001",
    #     current_plan=Plan.STANDARD,
    #     status=SubscriptionStatus.ACTIVE,
    #     period_started_at=datetime(2026,7,1,tzinfo=UTC),
    #     renews_at=datetime(2026,7,31,tzinfo=UTC),
    # )
    subscription = create_subscription()

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.PREMIUM,
        requested_at=datetime(2026,7,16,tzinfo=UTC),
    )

    actual = evaluate_plan_change(request)
    assert actual.timing is ChangeTiming.IMMEDIATE
    assert actual.effective_at == datetime(2026,7,16,tzinfo=UTC)
    assert actual.additional_charge == Decimal("500")

def test_downgrade_is_scheduled_for_next_renewal() -> None:
    """
    要件:
    現在プラン:
    Plan.PREMIUM
    申請プラン:
    Plan.STANDARD
    正常なACTIVE契約を作成する。
    結果について次を確認する。
    timing:
    ChangeTiming.NEXT_RENEWAL
    effective_at:
    subscription.renews_at
    additional_charge:
    Decimal("0")
    """
    # subscription = Subscription(
    #     customer_id="CUSTOMER-001",
    #     current_plan=Plan.PREMIUM,
    #     status=SubscriptionStatus.ACTIVE,
    #     period_started_at=datetime(2026,7,1,tzinfo=UTC),
    #     renews_at=datetime(2026,7,31,tzinfo=UTC),
    # )
    subscription = create_subscription(current_plan=Plan.PREMIUM)

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.STANDARD,
        requested_at=datetime(2026,7,16,tzinfo=UTC),
    )

    actual = evaluate_plan_change(request)
    assert actual.timing is ChangeTiming.NEXT_RENEWAL
    assert actual.effective_at == datetime(2026,7,31,tzinfo=UTC)
    assert actual.additional_charge == Decimal("0")

def test_same_plan_is_rejected() -> None:
    """
    要件:
    現在プランと申請プランの両方を
    Plan.STANDARDにする。
    結果について次を確認する。
    timing:
    ChangeTiming.REJECTED
    effective_at:
    None
    reason:
    "requested plan is already active"
    """
    # subscription = Subscription(
    #     customer_id="CUSTOMER-001",
    #     current_plan=Plan.STANDARD,
    #     status=SubscriptionStatus.ACTIVE,
    #     period_started_at=datetime(2026,7,1,tzinfo=UTC),
    #     renews_at=datetime(2026,7,31,tzinfo=UTC),
    # )
    subscription = create_subscription()

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.STANDARD,
        requested_at=datetime(2026,7,16,tzinfo=UTC),
    )

    actual = evaluate_plan_change(request)
    assert actual.timing is ChangeTiming.REJECTED
    assert actual.effective_at is None
    assert actual.reason == "requested plan is already active"

def test_payment_failed_subscription_is_rejected() -> None:
    """
    要件:
    契約状態:
    SubscriptionStatus.PAYMENT_FAILED
    Plan.STANDARDからPlan.PREMIUMへの
    変更を申請する。
    結果について次を確認する。
    timing:
    ChangeTiming.REJECTED
    reason:
    "payment is currently failing"
    """
    # subscription = Subscription(
    #     customer_id="CUSTOMER-001",
    #     current_plan=Plan.STANDARD,
    #     status=SubscriptionStatus.PAYMENT_FAILED,
    #     period_started_at=datetime(2026,7,1,tzinfo=UTC),
    #     renews_at=datetime(2026,7,31,tzinfo=UTC),
    # )
    subscription = create_subscription(status=SubscriptionStatus.PAYMENT_FAILED)

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.PREMIUM,
        requested_at=datetime(2026,7,16,tzinfo=UTC),
    )

    actual = evaluate_plan_change(request)
    assert actual.timing is ChangeTiming.REJECTED
    assert actual.reason == "payment is currently failing"

def test_cancelled_subscription_is_rejected() -> None:
    """
    要件:
    契約状態:
    SubscriptionStatus.CANCELLED
    結果について次を確認する。
    timing:
    ChangeTiming.REJECTED
    reason:
    "subscription is cancelled"
    """
    # subscription = Subscription(
    #     customer_id="CUSTOMER-001",
    #     current_plan=Plan.STANDARD,
    #     status=SubscriptionStatus.CANCELLED,
    #     period_started_at=datetime(2026,7,1,tzinfo=UTC),
    #     renews_at=datetime(2026,7,31,tzinfo=UTC),
    # )
    subscription = create_subscription(status=SubscriptionStatus.CANCELLED)

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.PREMIUM,
        requested_at=datetime(2026,7,16,tzinfo=UTC),
    )

    actual = evaluate_plan_change(request)
    assert actual.timing is ChangeTiming.REJECTED
    assert actual.reason == "subscription is cancelled"

def test_request_at_renewal_time_is_invalid() -> None:
    """
    要件:
    requested_atとrenews_atを
    同じ日時にする。
    evaluate_plan_change()を実行すると
    InvalidSubscriptionErrorが発生することを確認する。
    例外メッセージ:
    "requested_at must be before renews_at"
    """
    # subscription = Subscription(
    #     customer_id="CUSTOMER-001",
    #     current_plan=Plan.STANDARD,
    #     status=SubscriptionStatus.ACTIVE,
    #     period_started_at=datetime(2026,7,1,tzinfo=UTC),
    #     renews_at=datetime(2026,7,31,tzinfo=UTC),
    # )
    subscription = create_subscription()

    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=Plan.PREMIUM,
        requested_at=datetime(2026,7,31,tzinfo=UTC),
    )

    with pytest.raises(InvalidSubscriptionError) as exception_info:
        evaluate_plan_change(request)

    assert str(exception_info.value) == "requested_at must be before renews_at"

@pytest.mark.parametrize(
    (
        "current_plan",
        "requested_plan",
        "expected_timing",
    ),
    [
        (
            Plan.FREE,
            Plan.STANDARD,
            ChangeTiming.IMMEDIATE,
        ),
        (
            Plan.FREE,
            Plan.PREMIUM,
            ChangeTiming.IMMEDIATE,
        ),
        (
            Plan.STANDARD,
            Plan.PREMIUM,
            ChangeTiming.IMMEDIATE,
        ),
        (
            Plan.PREMIUM,
            Plan.STANDARD,
            ChangeTiming.NEXT_RENEWAL,
        ),
        (
            Plan.PREMIUM,
            Plan.FREE,
            ChangeTiming.NEXT_RENEWAL,
        ),
        (
            Plan.STANDARD,
            Plan.FREE,
            ChangeTiming.NEXT_RENEWAL,
        ),
    ],
)
def test_plan_change_timing(
    current_plan: Plan,
    requested_plan: Plan,
    expected_timing: ChangeTiming,
) -> None:
    """
    要件:
    pytest.mark.parametrizeから次を受け取る。
    current_plan
    requested_plan
    expected_timing
    ACTIVE状態の契約を作成する。
    evaluate_plan_change()を実行する。
    decision.timingが
    expected_timingと一致することを確認する。
    """
    subscription = create_subscription(current_plan=current_plan)
    request = PlanChangeRequest(
        subscription=subscription,
        requested_plan=requested_plan,
        requested_at=datetime(2026,7,16,tzinfo=UTC)
    )
    actual = evaluate_plan_change(request)
    assert actual.timing is expected_timing
