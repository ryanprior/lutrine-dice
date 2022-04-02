module Rooms
  ( actions
  , newRoomButtonDisplay
  , newRoomName
  , proposition
  , readyWhen
  )
  where

import Quickstrom
import Data.Maybe (Maybe(..), isJust, isNothing)

readyWhen :: Selector
readyWhen = "#rooms"

rooms = queryOne "#rooms" {}

chat = queryOne "section.af" {}

newRoomButtonDisplay :: Maybe String
newRoomButtonDisplay = map _.display (queryOne "a.new-room.r" { display: cssValue "display"})

newRoomName :: Maybe String
newRoomName = map _.value (queryOne "#rooms form input" { value })

actions :: Actions
actions =
  clicks
    <> [ click "a.new-room"
         `followedBy` enterText "new-quickstrom-room"
       ]
    -- <> [ click "form.r button" ]
    <> [ click "h2" ]

proposition :: Boolean
proposition =
  let

    buttonHidden = newRoomButtonDisplay == Just "none"
                   || newRoomButtonDisplay == Nothing

    noName = newRoomName == Nothing
             || newRoomName == Just ""

    filledName = newRoomName == Just "new-quickstrom-room"

    initial = (isJust rooms) && (not buttonHidden) && noName

    goCreate = (not buttonHidden)
               && next buttonHidden
               && next filledName

    cancelCreate = buttonHidden
                   && next noName
                   && next (not buttonHidden)

    visitNewRoom = filledName
                   && next (isJust chat)
                   && next (isNothing rooms)

    addName = noName && not next noName

    noop = newRoomName == next newRoomName
           && newRoomButtonDisplay == next newRoomButtonDisplay
  in
   initial
   && always ((isJust rooms) `implies` (goCreate || addName || cancelCreate || noop))
