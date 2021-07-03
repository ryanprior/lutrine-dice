component Chat {
  connect Messages exposing { list, update }

  state socket : Maybe(WebSocket) = Maybe::Nothing
  state message : String = ""
  state username : String = "Gamer"
  state shouldConnect = true
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

  use Provider.WebSocket {
    url = "ws://localhost:3000/chat",
    reconnectOnClose = true,
    onMessage = handleMessage,
    onError = handleError,
    onClose = handleClose,
    onOpen = handleOpen
  } when {
    shouldConnect
  }

  fun handleMessage(data: String) : Promise(Never, Void) {
    try {
      object = Json.parse(data) |> Maybe.toResult("Decode Error")
      action = MessageAction.In.fromJSON(object)

      data |> Debug.log
      update(action)
    }

    catch Object.Error => err {
      sequence {
        err |> Debug.log
        next {}
      }
    } catch String => err {
      sequence {
        err |> Debug.log
        next {}
      }
    }
  }

  fun handleError : Promise(Never, Void) {
    sequence {
      void
    }
  }
  fun handleClose : Promise(Never, Void) {
    sequence {
      void
    }
  }
  fun handleOpen(socket : WebSocket) {
    next {
      socket = Maybe::Just(socket)
    }
  }

  fun updateMessage(event: Html.Event) : Promise(Never, Void) {
    next {
      message = Dom.getValue(event.target)
    }
  }

  fun sendMessage(event: Html.Event) : Promise(Never, Void) {
    sequence {
      event |> Html.Event.preventDefault()
      /* send message to websocket */
      case (socket) {
        Maybe::Just(websocket) => WebSocket.send(jsonMessage, websocket)
        => next {  }
      }
      /* reset message to empty */
      next {
        message = ""
      }
      next {
        currentExample = Array.sample(examples)
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

  style chat {
    width: 90ex;
    background: #32373B;
    border-radius: 0px 0px 0.5rem 0.5rem;
    margin-bottom: 6rem;
    min-height: 60%;
    padding: 0.8rem 1rem 3rem 1rem;
  }

  style messageInput {
    width: calc(100% - 0.6rem);
  }

  style messages {
    color: #EFF4E8;
    list-style: none;
    padding: 0px;
  }

  fun render : Html {
    <div::chat>
      <form onSubmit={ sendMessage }>
        <input::messageInput
          placeholder="ex: #{currentExample |> Maybe.withDefault("1d20")}"
          autofocus="true"
          value={ message }
          onInput={ updateMessage }
        />
      </form>
      <ol::messages>
        for (msg of Array.reverse(list)) {
          <li><Message data={msg} /></li>
        }
      </ol>
    </div>
  }
}
