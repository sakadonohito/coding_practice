package booking

import "fmt"

// RoomTypeは会議室の種類を表す独自型です。
//
// 通常のstringをそのまま使うよりも、
// 「これは会議室の種類を表す値である」と明確にできます。
type RoomType string

const (
	RoomTypeStandard RoomType = "standard"
	RoomTypeLarge    RoomType = "large"
)

// PricingRequestは料金計算に必要な入力値をまとめた構造体です。
type PricingRequest struct {
	RoomType  RoomType
	Hours     int
	People    int
	IsHoliday bool
}

// PricingResultは料金の内訳と合計をまとめた構造体です。
//
// 金額はすべて円単位のintで扱います。
// これにより、小数計算による誤差を避けられます。
type PricingResult struct {
	BaseCharge             int
	AdditionalPeopleCharge int
	HolidaySurcharge       int
	Total                  int
}

// CalculatePriceは会議室の予約料金を計算します。
func CalculatePrice(request PricingRequest) (PricingResult, error) {
	if err := validateRequest(request); err != nil {
		return PricingResult{}, err
	}

	hourlyRate, includedPeople := roomPricing(request.RoomType)

	baseCharge := hourlyRate * request.Hours

	additionalPeople := request.People - includedPeople
	if additionalPeople < 0 {
		additionalPeople = 0
	}

	additionalPeopleCharge :=
		additionalPeople * 300 * request.Hours

	subtotal := baseCharge + additionalPeopleCharge

	holidaySurcharge := 0
	if request.IsHoliday {
		holidaySurcharge = subtotal * 20 / 100
	}

	total := subtotal + holidaySurcharge

	return PricingResult{
		BaseCharge:             baseCharge,
		AdditionalPeopleCharge: additionalPeopleCharge,
		HolidaySurcharge:       holidaySurcharge,
		Total:                  total,
	}, nil
}

// validateRequestは入力値が正しいかを検証します。
func validateRequest(request PricingRequest) error {
	switch request.RoomType {
	case RoomTypeStandard, RoomTypeLarge:
		// 使用可能な会議室なので、そのまま後続の検証へ進みます。
	default:
		return fmt.Errorf(
			"unsupported room type: %q",
			request.RoomType,
		)
	}

	if request.Hours < 1 || request.Hours > 8 {
		return fmt.Errorf(
			"hours must be between 1 and 8: %d",
			request.Hours,
		)
	}

	if request.People < 1 {
		return fmt.Errorf(
			"people must be at least 1: %d",
			request.People,
		)
	}

	return nil
}

// roomPricingは、会議室ごとの時間料金と基本人数を返します。
func roomPricing(roomType RoomType) (
	hourlyRate int,
	includedPeople int,
) {
	switch roomType {
	case RoomTypeStandard:
		return 2000, 6

	case RoomTypeLarge:
		return 5000, 10

	default:
		// この関数は、入力検証が終わった後に呼ばれる想定です。
		// そのため、通常ここには到達しません。
		return 0, 0
	}
}
