component Chat {
  connect Api exposing { endpoint }
  connect Messages exposing { list, update }
  connect Theme exposing { theme }
  connect Characters exposing { character }

  property room : String
  property roomKey : String
  state socket : Maybe(WebSocket) = Maybe::Nothing
  state shouldConnect = true

  use Provider.WebSocket {
    url = "ws://#{endpoint}/chat/#{room}?key=#{roomKey}",
    reconnectOnClose = true,
    onMessage = handleMessage,
    onError = handleError,
    onClose = handleClose,
    onOpen = handleOpen
  } when {
    shouldConnect
  }

  fun handleMessage(data: String) {
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

  fun handleError {
    sequence {
      void
    }
  }
  fun handleClose {
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
    flex-grow: 1;
    background-color: #{theme.chat.background};
    overflow-x: hidden;
    overflow-y: scroll;
    padding: 0.8rem 1rem 3rem 1rem;
  }

  style messages {
    color: #{theme.chat.textColor};
    list-style: none;
    padding: 0px;
    display: grid;
    grid-template-columns: 6rem 1fr;
    grid-gap: 0px;
  }

  style message {
    display: contents;
    word-break: break-word;
  }

  fun render : Html {
    <section::chat>
      <Chat.Input username={character.name} socket={socket} />
      <ol::messages>
        for (msg of Array.reverse(list)) {
          <li::message><Message data={msg} /></li>
        }
      </ol>
    </section>
  }
}
