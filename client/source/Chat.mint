component Chat {
  connect Messages exposing { list, add }

  state socket : Maybe(WebSocket) = Maybe::Nothing
  state message : String = ""
  state shouldConnect = true

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
    sequence {
      data |> Debug.log()
      add(data)
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
        Maybe::Just websocket => WebSocket.send(message, websocket)
        => next {  }
      }
      /* reset message to empty */
      next {
        message = ""
      }
    }
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
        for (msg of list) {
          <li><{ msg.text }></li>
        }
      </ol>
    </div>
  }
}
