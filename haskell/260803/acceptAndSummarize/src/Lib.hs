module Lib
  ( ReservationRequest (..),
    AcceptedReservation,
    ReservationError (..),
    acceptReservation,
    reservationSummary,
    acceptAndSummarize,
  )
where

data ReservationRequest = ReservationRequest
  { customerName :: String,
    partySize :: Int
  }
  deriving (Eq, Show)

data AcceptedReservation = AcceptedReservation
  { acceptedCustomerName :: String,
    acceptedPartySize :: Int
  }
  deriving (Eq, Show)

data ReservationError
  = CustomerNameMustNotBeEmpty
  | PartySizeMustBePositive Int
  | PartySizeExceedsLimit
      { requestedPartySize :: Int,
        maximumPartySize :: Int
      }
  deriving (Eq, Show)

acceptReservation ::
  ReservationRequest ->
  Either ReservationError AcceptedReservation
acceptReservation request
  | name == "" =
      Left CustomerNameMustNotBeEmpty
  | nop <= 0 =
      Left (PartySizeMustBePositive nop)
  | 8 < nop =
      Left
        ( PartySizeExceedsLimit
            { requestedPartySize = nop,
              maximumPartySize = 8
            }
        )
  | otherwise =
      Right
        ( AcceptedReservation
            { acceptedCustomerName = name,
              acceptedPartySize = nop
            }
        )
  where
    name = customerName request
    -- number of people
    nop = partySize request

reservationSummary :: AcceptedReservation -> String
reservationSummary accepted =
  name ++ ": " ++ (show nop) ++ "名"
  where
    name = acceptedCustomerName accepted
    nop = acceptedPartySize accepted

acceptAndSummarize ::
  ReservationRequest ->
  Either ReservationError String
acceptAndSummarize request =
  fmap reservationSummary (acceptReservation request)
