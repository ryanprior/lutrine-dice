store Realtime {
  state shouldConnect = false
  state socket : Maybe(WebSocket) = Maybe::Nothing

  fun connect {
    next {
      shouldConnect = true
    }
  }

  fun disconnect {
    next {
      shouldConnect = false
    }
  }

  fun closeSocket {
    next {
      socket = Maybe::Nothing
    }
  }

  fun openSocket(socket : WebSocket) {
    next {
      socket = Maybe::Just(socket)
    }
  }
}

component Chat {
  connect Api exposing { ws }
  connect Messages exposing { list, update }
  connect Theme exposing { theme }
  connect Characters exposing { character }
  connect Realtime exposing { shouldConnect, socket }

  property room : Room
  property roomKey : String

  use Provider.WebSocket {
    url = "#{ws}/chat/#{room.id}?key=#{roomKey}",
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
      action = MessageAction.In.fromObject(object)

      update(action, room)
    }

    catch Object.Error => error {
      sequence {
        ({error, "handleMessage Object.Error"}) |> Debug.log
        next {}
      }
    } catch String => error {
      sequence {
        ({error, "handleMessage String error"}) |> Debug.log
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
    Realtime.closeSocket()
  }
  fun handleOpen(socket : WebSocket) {
    Realtime.openSocket(socket)
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
    grid-template-columns: 2rem 1fr;
    grid-gap: 0px;
  }

  style message {
    display: contents;
    word-break: break-word;

    &:not(:first-child) .whomst {
      border-top: 1px dotted #495057;
    }
  }

  fun render {
    <section::chat>
      <Chat.Input username={character.name} socket={socket} />
      <ol::messages>
      for (data of displays) {
          <li::message><MessageDisplay data={data[0]} first={data[1]} mostRecent={data[2]} /></li>
        }
      </ol>
    </section>
  } where {
    messages =
      list
      |> Map.get(room)
      |> Maybe.withDefault([])
      |> Array.reverse
    displays =
      messages
      |> Array.mapWithIndex((msg : Message, n : Number) : Tuple(Message, Bool, Bool) {
        case (messages |> Array.at(n - 1)) {
          Maybe::Just(prev) => {msg, msg.from != prev.from, n == 0}
            => {msg, true, n == 0}
        }
      })
  }
}
