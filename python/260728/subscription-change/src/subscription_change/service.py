from datetime import datetime
from decimal import Decimal, ROUND_HALF_UP

from subscription_change.models import (
    ChangeTiming,
    Plan,
    PlanChangeDecision,
    PlanChangeRequest,
    SubscriptionStatus
)

class InvalidSubscriptionError(ValueError):
    """契約データ自体が不正な場合の例外。"""

def evaluate_plan_change(
        request: PlanChangeRequest,
) -> PlanChangeDecision:
    _validate_request(request)

    subscription = request.subscription

    match subscription.status:
        case SubscriptionStatus.PAYMENT_FAILED:
            return PlanChangeDecision(
                timing=ChangeTiming.REJECTED,
                current_plan=subscription.current_plan,
                requested_plan=request.requested_plan,
                effective_at=None,
                additional_charge=Decimal("0"),
                reason="payment is currently failing",
            )
        case SubscriptionStatus.CANCELLED:
            return PlanChangeDecision(
                timing=ChangeTiming.REJECTED,
                current_plan=subscription.current_plan,
                requested_plan=request.requested_plan,
                effective_at=None,
                additional_charge=Decimal("0"),
                reason="subscription is cancelled",
            )
        case SubscriptionStatus.ACTIVE:
            pass

    if request.requested_plan == subscription.current_plan:
        return PlanChangeDecision(
            timing=ChangeTiming.REJECTED,
            current_plan=subscription.current_plan,
            requested_plan=request.requested_plan,
            effective_at=None,
            additional_charge=Decimal("0"),
            reason="requested plan is already active",
        )

    if request.requested_plan.rank > subscription.current_plan.rank:
        charge = _calculate_prorated_charge(request)

        return PlanChangeDecision(
            timing=ChangeTiming.IMMEDIATE,
            current_plan=subscription.current_plan,
            requested_plan=request.requested_plan,
            effective_at=request.requested_at,
            additional_charge=charge,
        )

    return PlanChangeDecision(
        timing=ChangeTiming.NEXT_RENEWAL,
        current_plan=subscription.current_plan,
        requested_plan=request.requested_plan,
        effective_at=subscription.renews_at,
        additional_charge=Decimal("0"),
    )

def _validate_request(
        request: PlanChangeRequest,
) -> None:
    subscription = request.subscription

    if not subscription.customer_id.strip():
        raise InvalidSubscriptionError(
            "customer_id must not be blank"
        )

    if subscription.period_started_at >= subscription.renews_at:
        raise InvalidSubscriptionError(
            "period_started_at must be before renews_at"
        )

    if request.requested_at >= subscription.renews_at:
        raise InvalidSubscriptionError(
            "requested_at must be before renews_at"
        )

    if request.requested_at < subscription.period_started_at:
        raise InvalidSubscriptionError(
            "requested_at must not be before period_started_at"
        )

def _calculate_prorated_charge(
        request: PlanChangeRequest,
) -> Decimal:
    subscription = request.subscription

    total_seconds = Decimal(
        str(
            (
                subscription.renews_at - subscription.period_started_at
            ).total_seconds()
        )
    )

    remaining_seconds = Decimal(
        str(
            (
                subscription.renews_at - request.requested_at
            ).total_seconds()
        )
    )

    price_difference = (
        request.requested_plan.monthly_price - subscription.current_plan.monthly_price
    )

    charge = (
        price_difference * remaining_seconds / total_seconds
    )

    return charge.quantize(
        Decimal("1"),
        rounding=ROUND_HALF_UP,
    )
