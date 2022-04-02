module Rooms
  ( actions
  , newRoomButtonDisplay
  , newRoomName
  , proposition
  , readyWhen
  )
  where

import Quickstrom
import Data.Maybe (Maybe(..))

readyWhen :: Selector
readyWhen = "#rooms"

newRoomButtonDisplay :: Maybe String
newRoomButtonDisplay = case (queryOne "a.new-room.r" { display: cssValue "display"}) of
  Just el -> Just el.display
  Nothing -> Nothing

newRoomName :: Maybe String
newRoomName = case queryOne ".rooms form input" { value } of
  Just el -> Just el.value
  Nothing -> Nothing

actions :: Actions
actions =
  clicks
    <> [ click "a.new-room"
         `followedBy` enterText "new-quickstrom-room"
         `followedBy` click "form.r button"
       ]

proposition :: Boolean
proposition =
  let
    buttonHidden = newRoomButtonDisplay == Just "none"

    goCreate = buttonHidden && next (not buttonHidden)

    doneCreate = (not buttonHidden) && next buttonHidden

    noName = newRoomName == Nothing

    addName = noName && next newRoomName == Just "new-quickstrom-room"

    noop = noName && next noName
  in
   always (goCreate || doneCreate || addName || noop)
