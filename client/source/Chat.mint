component Chat {
  connect Messages exposing { list, update }

  state socket : Maybe(WebSocket) = Maybe::Nothing
  state username : String = "Gamer"
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
    try {
      object = Json.parse(data) |> Maybe.toResult("Decode Error")
      action = MessageAction.In.fromJSON(object)

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
    next {
      socket = Maybe::Nothing
    }
  }
  fun handleOpen(socket : WebSocket) {
    next {
      socket = Maybe::Just(socket)
    }
  }

  style chat {
    width: 90ex;
    background: #32373B;
    border-radius: 0px 0px 0.5rem 0.5rem;
    margin-bottom: 6rem;
    min-height: 60%;
    padding: 0.8rem 1rem 3rem 1rem;
  }

  style messages {
    color: #EFF4E8;
    list-style: none;
    padding: 0px;
  }

  fun render : Html {
    <div::chat>
      <Chat.Input username={username} socket={socket} />
      <ol::messages>
        for (msg of Array.reverse(list)) {
          <li><Message data={msg} /></li>
        }
      </ol>
    </div>
  }
}
