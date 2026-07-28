from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from enum import StrEnum

class Plan(StrEnum):
    FREE = "free"
    STANDARD = "standard"
    PREMIUM = "premium"

    @property
    def monthly_price(self) -> Decimal:
        match self:
            case Plan.FREE:
                return Decimal("0")
            case Plan.STANDARD:
                return Decimal("980")
            case Plan.PREMIUM:
                return Decimal("1980")

    @property
    def rank(self) -> int:
        match self:
            case Plan.FREE:
                return 0
            case Plan.STANDARD:
                return 1
            case Plan.PREMIUM:
                return 2

class SubscriptionStatus(StrEnum):
    ACTIVE = "active"
    PAYMENT_FAILED = "payment_failed"
    CANCELLED = "cancelled"

class ChangeTiming(StrEnum):
    IMMEDIATE = "immediate"
    NEXT_RENEWAL = "next_renewal"
    REJECTED = "rejected"

@dataclass(frozen=True, slots=True, kw_only=True)
class Subscription:
    customer_id: str
    current_plan: Plan
    status: SubscriptionStatus
    period_started_at: datetime
    renews_at: datetime

@dataclass(frozen=True, slots=True, kw_only=True)
class PlanChangeRequest:
    subscription: Subscription
    requested_plan: Plan
    requested_at: datetime

@dataclass(frozen=True, slots=True, kw_only=True)
class PlanChangeDecision:
    timing: ChangeTiming
    current_plan: Plan
    requested_plan: Plan
    effective_at: datetime | None
    additional_charge: Decimal
    reason: str | None = None
