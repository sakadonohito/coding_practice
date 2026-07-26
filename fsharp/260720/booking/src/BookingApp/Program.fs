module Program

open BookingAppService

[<EntryPoint>]
let main argv =
    let existings: Reservation list =
        [ { Title = "朝会"
            StartHour = 9
            EndHour = 10 }
          { Title = "企画会議"
            StartHour = 13
            EndHour = 15 } ]

    let actual = createReservation 9 18 existings "定例会議" 10 11
    printfn "%A" actual
    0
