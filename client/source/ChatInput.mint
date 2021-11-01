component Chat.Input {
  property username : String
  property socket : Maybe(WebSocket)

  state message = ""
  state examples = [
    "1d20",
    "1d12",
    "1d10",
    "1d8",
    "1d6",
    "1d4",
    "1d20+2",
    "2d12+11",
    "3d10-1",
    "4d8+2",
    "3d6-2",
    "2d4+1",
    "1d100",
    "1d6+1d4",
    "1d8+1d6",
    "1d10+1d8",
    "1d12+1d10",
    "Ray of Frost spell attack 1d20+5 and ❄ cold damage 1d8",
    "Longsword attack ⚔ 1d20+1d4+8 (bless) and slashing damage 1d8+4",
    "Wisdom save against fear 😱 1d20+3 cmon no scarey 🙏🏾",
    "Rolling for loot 💰✨ 1d100 ✨💰",
    "The sky is falling ☄ everybody take 1d10+3d6 bludgeoning damage (Dex save for half)",
    "Putting Goblins to sleep 💤 5d8 HP total 💤",
  ]
  state currentExample : Maybe(String) = Maybe::Nothing

  get disconnected : Bool {
    socket |> Maybe.isNothing
  }

  fun componentDidMount {
    next {
      currentExample = Array.sample(examples)
    }
  }

  fun sendMessage(event: Html.Event) {
    sequence {
      event |> Html.Event.preventDefault()
      case (socket) {
        Maybe::Just(websocket) => sequence {
          WebSocket.send(jsonMessage, websocket)
          /* reset message to empty */
          next {
            message = ""
          }
          next {
            currentExample = Array.sample(examples)
          }
        }
        => next {}
      }
    }
  } where {
    messageObject = encode {
      type = "message",
      from = {name = username},
      message = message
    }
    jsonMessage = Json.stringify(messageObject)
  }

  style messageInput {
    width: calc(100% - 0.6rem);
  }

  fun updateMessage(event: Html.Event) {
    next {
      message = Dom.getValue(event.target)
    }
  }

  fun render {
    <form onSubmit={ sendMessage }>
      <input::messageInput
        placeholder="ex: #{currentExample |> Maybe.withDefault("1d20")}"
        autofocus="true"
        value={message}
        onInput={updateMessage}
        disabled={disconnected}
      />
    </form>
  }
}
