component Rooms {
  property data : Array(RoomKey)

  state newRoomName : Maybe(String) = Maybe::Nothing

  connect Theme exposing { theme }

  style rooms {
    list-style: none;
    color: #{theme.interface.textColor};
    padding: 8px 0px;

    & a {
      color: #{theme.interface.textColor};
    }

    & ul {
      list-style: none;
      margin: 0px;
      padding: 0px;

      & li {
        margin: 0px;
        &::before {
          content: "> ";
        }
      }
    }
  }

  fun startCreating(event : Html.Event) {
    try {
      event |> Html.Event.preventDefault
      next {
        newRoomName = Maybe::Just("")
      }
      case(input) {
        Maybe::Just(element) => Dom.focusWhenVisible(element)
          => `console.log('nope')` as Promise(String, Void)
      }
    }
  }

  fun updateNewName(event : Html.Event) {
    next {
      newRoomName = Maybe::Just(Dom.getValue(event.target))
    }
  }

  fun handleNewRoom(event : Html.Event) {
    sequence {
      event |> Html.Event.preventDefault
      response = case(input) {
        Maybe::Just(element) => Api.createRoom(Dom.getValue(element))
          => `console.log('no input?')` as Promise(Http.ErrorResponse, Http.Response)
      }
      object = Json.parse(response.body)
        |> Maybe.toResult("")
      data = decode object as RoomKey
      Application.acceptInvite(data)
      Window.navigate("/room/#{data.room.id}/#{data.room.name}")
    } catch Http.ErrorResponse => error {
      sequence {
        ({error, "handleNewRoom Http.ErrorResponse"}) |> Debug.log
        next {}
      }
    } catch Storage.Error => error {
      sequence {
        ({error, "handleNewRoom Storage.Error"}) |> Debug.log
        next {}
      }
    } catch Object.Error => error {
      sequence {
        ({error, "handleNewRoom Object.Error"}) |> Debug.log
        next {}
      }
    } catch String => error {
      sequence {
        ({error, "handleNewRoom String error"}) |> Debug.log
        next {}
      }
    }
  }

  style createRoom(invert : Bool) {
    if(`#{Maybe.isNothing(newRoomName)} ^ #{invert}`) {
      display: none;
    }
  }

  fun render {
    <div::rooms>
      "Join a room"
      <ul>
        for (roomKey of data) {
          <li><a href="/room/#{roomKey.room.id}/#{roomKey.room.name}"><{ roomKey.room.name }></a></li>
        }
      </ul>
      <a::createRoom(true) href="#" onClick={startCreating}>"+ Create a room"</a>
      <form::createRoom(false) onSubmit={handleNewRoom}>
        "Name your room: "
        <input as input
               value={newRoomName |> Maybe.withDefault("")}
               onInput={updateNewName}
               type="text" />
        <button>"Create"</button>
      </form>
    </div>
  }
}
