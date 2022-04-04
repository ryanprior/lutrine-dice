module Rooms where

import Quickstrom
import Data.Maybe (Maybe(..), isJust, isNothing)

readyWhen :: Selector
readyWhen = "#rooms"

rooms = queryOne "#rooms" {}

newRoomButtonDisplay :: Maybe String
newRoomButtonDisplay = map _.display (
  queryOne "[data-role=\"create-room\"]" { display: cssValue "display"}
  )

newRoomName :: Maybe String
newRoomName = map _.value (queryOne "input[data-role=\"new-room-name\"]" { value, outline: cssValue "outline-color" })

newRoomOutline :: Maybe String
newRoomOutline = map _.outline (
  queryOne "input.ai" { outline: cssValue "outline-color" }
  )

actions :: Actions
actions =
  clicks
    <> [ click "[data-role=\"create-room\"]"
         `followedBy` enterText "new-quickstrom-room"
       ]
    <> [ click "h2" ]

proposition :: Boolean
proposition =
  let
    buttonHidden = newRoomButtonDisplay == Just "none"

    noName = newRoomName == Nothing
             || newRoomName == Just ""

    nameError = newRoomOutline == Just "rgb(255, 0, 0)"

    createEmpty = noName
                 && (not nameError)
                 && next nameError

    filledName = newRoomName == Just "new-quickstrom-room"

    initial = noName && not buttonHidden

    goCreate = (not buttonHidden)
               && next buttonHidden

    cancelCreate = buttonHidden
                   && next (noName && (not buttonHidden))

    void = isNothing rooms
  in
   initial
   && always void || (
     (goCreate || cancelCreate || unchanged [newRoomName, newRoomButtonDisplay])
     && (createEmpty || cancelCreate || unchanged newRoomOutline)
     )
