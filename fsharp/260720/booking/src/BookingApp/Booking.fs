module BookingAppService

type Reservation =
    { Title: string
      StartHour: int
      EndHour: int }

type BookingError =
    | EmptyTitle
    | InvalidTimeRange
    | OutsideBusinessHours
    | OverlappingReservation of existingTitle: string

let private overlaps (startHour: int) (endHour: int) (existing: Reservation) : bool =

    startHour < existing.EndHour && endHour > existing.StartHour

let createReservation
    (businessStartHour: int)
    (businessEndHour: int)
    (existingReservations: Reservation list)
    (title: string)
    (startHour: int)
    (endHour: int)
    : Result<Reservation, BookingError> =

    let normalizedTitle = title.Trim()

    if normalizedTitle = "" then
        Error EmptyTitle

    elif startHour >= endHour then
        Error InvalidTimeRange

    elif startHour < businessStartHour || endHour > businessEndHour then
        Error OutsideBusinessHours

    else
        let overlappingReservation =
            existingReservations |> List.tryFind (overlaps startHour endHour)

        match overlappingReservation with
        | Some reservation -> Error(OverlappingReservation reservation.Title)

        | None ->
            Ok
                { Title = normalizedTitle
                  StartHour = startHour
                  EndHour = endHour }
