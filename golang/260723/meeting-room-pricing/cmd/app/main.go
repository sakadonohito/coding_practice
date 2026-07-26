package main

import (
	"fmt"
	"log"

	"example.com/meeting-room-pricing/internal/booking"
)

func main() {
	request := booking.PricingRequest{
		RoomType:  booking.RoomTypeLarge,
		Hours:     2,
		People:    15,
		IsHoliday: true,
	}

	result, err := booking.CalculatePrice(request)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("基本料金: %d円\n", result.BaseCharge)
	fmt.Printf(
		"人数追加料金: %d円\n",
		result.AdditionalPeopleCharge,
	)
	fmt.Printf(
		"休日割増料金: %d円\n",
		result.HolidaySurcharge,
	)
	fmt.Printf("合計料金: %d円\n", result.Total)
}
