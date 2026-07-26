package booking

import (
	"testing"
)

func TestCalculatePriceStandardRoom(t *testing.T) {
	// 要件:
	// 標準会議室を平日に3時間、5人で利用する。
	//
	// 標準会議室の時間料金は2,000円である。
	// 基本人数は6人なので、人数追加料金は発生しない。
	// 平日なので休日割増料金は発生しない。
	//
	// 次の結果になることを確認する。
	//
	// BaseCharge:             6000
	// AdditionalPeopleCharge: 0
	// HolidaySurcharge:       0
	// Total:                  6000
	request := PricingRequest{
		RoomType:  RoomTypeStandard,
		Hours:     3,
		People:    5,
		IsHoliday: false,
	}
	got, err := CalculatePrice(request)
	if err != nil {
		t.Fatalf("CalculatePrice() error = %v", err)
	}
	want := PricingResult{
		BaseCharge:             6000,
		AdditionalPeopleCharge: 0,
		HolidaySurcharge:       0,
		Total:                  6000,
	}
	if got != want {
		t.Errorf("CalculatePrice() = %+v, want %+v", got, want)
	}
}

func TestCalculatePriceLargeRoomOnHoliday(t *testing.T) {
	// 要件:
	// 大会議室を休日に2時間、15人で利用する。
	//
	// 基本料金:
	// 5,000円 × 2時間 = 10,000円
	//
	// 大会議室の基本人数は10人なので、
	// 追加人数は5人である。
	//
	// 人数追加料金:
	// 5人 × 300円 × 2時間 = 3,000円
	//
	// 小計:
	// 10,000円 + 3,000円 = 13,000円
	//
	// 休日割増料金:
	// 13,000円 × 20% = 2,600円
	//
	// 合計:
	// 13,000円 + 2,600円 = 15,600円
	//
	// 次の結果になることを確認する。
	//
	// BaseCharge:             10000
	// AdditionalPeopleCharge: 3000
	// HolidaySurcharge:       2600
	// Total:                  15600
	request := PricingRequest{
		RoomType:  RoomTypeLarge,
		Hours:     2,
		People:    15,
		IsHoliday: true,
	}
	got, err := CalculatePrice(request)
	if err != nil {
		t.Fatalf("CalculatePrice() error = %v", err)
	}
	want := PricingResult{
		BaseCharge:             10000,
		AdditionalPeopleCharge: 3000,
		HolidaySurcharge:       2600,
		Total:                  15600,
	}
	if got != want {
		t.Errorf("CalculatePrice() = %+v, want %+v", got, want)
	}
}

func TestCalculatePriceRejectsInvalidHours(t *testing.T) {
	// 要件:
	// 利用時間に0を指定してCalculatePriceを実行する。
	//
	// errorがnilではないことを確認する。
	//
	// さらに、エラーメッセージが次の文字列であることを確認する。
	//
	// "hours must be between 1 and 8: 0"
	request := PricingRequest{
		RoomType:  RoomTypeLarge,
		Hours:     0,
		People:    1,
		IsHoliday: false,
	}
	got, err := CalculatePrice(request)
	if err == nil {
		t.Fatalf("CalculatePrice() got = %+v", got)
	}
	want := "hours must be between 1 and 8: 0"
	if err.Error() != want {
		t.Errorf("CalculatePrice() = %+v, want %+v", err.Error(), want)
	}
}

func TestCalculatePriceRejectsUnsupportedRoomType(
	t *testing.T,
) {
	// 要件:
	// RoomTypeに"vip"を指定してCalculatePriceを実行する。
	// errorがnilではないことを確認する。
	// さらに、エラーメッセージが次の文字列であることを確認する。
	// `unsupported room type: "vip"`
	request := PricingRequest{
		RoomType:  "vip",
		Hours:     1,
		People:    1,
		IsHoliday: false,
	}
	got, err := CalculatePrice(request)
	if err == nil {
		t.Fatalf("CalculatePrice() got = %+v", got)
	}
	want := `unsupported room type: "vip"`
	if err.Error() != want {
		t.Errorf("CalculatePrice() = %+v, want %+v", err.Error(), want)
	}
}

func TestCalculatePriceWithTableDrivenTests(t *testing.T) {
	// 各ケースをt.Runでサブテストとして実行する。
	tests := []struct {
		name    string
		request PricingRequest
		want    int
	}{
		{
			// ケース1:
			// 名前: "標準会議室の基本人数以内"
			// RoomType: RoomTypeStandard
			// Hours: 1
			// People: 6
			// IsHoliday: false
			// 期待するTotal: 2000
			name: "標準会議室の基本人数以内",
			request: PricingRequest{
				RoomType:  RoomTypeStandard,
				Hours:     1,
				People:    6,
				IsHoliday: false,
			},
			want: 2000,
		},
		{
			// ケース2:
			// 名前: "標準会議室の基本人数超過"
			// RoomType: RoomTypeStandard
			// Hours: 2
			// People: 8
			// IsHoliday: false
			// 期待するTotal: 5200
			name: "標準会議室の基本人数超過",
			request: PricingRequest{
				RoomType:  RoomTypeStandard,
				Hours:     2,
				People:    8,
				IsHoliday: false,
			},
			want: 5200,
		},
		{
			// ケース3:
			// 名前: "大会議室の休日利用"
			// RoomType: RoomTypeLarge
			// Hours: 1
			// People: 10
			// IsHoliday: true
			// 期待するTotal: 6000
			name: "大会議室の休日利用",
			request: PricingRequest{
				RoomType:  RoomTypeLarge,
				Hours:     1,
				People:    10,
				IsHoliday: true,
			},
			want: 6000,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := CalculatePrice(tt.request)
			if err != nil {
				t.Fatalf("CalculatePrice() error = %v", err)
			}
			if got.Total != tt.want {
				t.Errorf("CalculatePrice() = %+v, want %+v", got, tt.want)
			}
		})
	}

}
