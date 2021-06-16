component Chat {
  connect Messages exposing { list, update }

  state socket : Maybe(WebSocket) = Maybe::Nothing
  state message : String = ""
  state username : String = "Gamer"
  state shouldConnect = true
  state poast = {
    from = {name = "J. Random Gamer"},
    parts = [
      Message.Part::Text("Hello world!"),
      Message.Part::Rolls([{
        dice = {
          count = 2,
          sides = 6,
          constant = 1
        },
        results = [2, 6]
      }])
    ]
  }

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
      action = decode object as MessageAction.In

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
        Maybe::Just websocket => WebSocket.send(jsonMessage, websocket)
        => next {  }
      }
      /* reset message to empty */
      next {
        message = ""
      }
    }
  } where {
    messageObject = encode {
      type = "message",
      from = {name = username},
      message = message
    }
    jsonMessage = Json.Stringify(messageObject)
  }

  fun render : Html {
    <div>
      <form onSubmit={ sendMessage }>
        <input
          placeholder="message…"
          autofocus="true"
          value={ message }
          onInput={ updateMessage }
        />
      </form>
      <ol>
        <Post data={poast} />
        for (msg of list) {
          <li><{ msg.text }></li>
        }
      </ol>
    </div>
  }
}
