component Rooms {
  property data : Array(RoomKey)

  state newRoomName : Maybe(String) = Maybe::Nothing
  state aggro = false

  connect Theme exposing { theme }

  use Provider.OutsideClick {
    clicks = cancelCreating,
    elements = [newRoomForm]
  } when {
    Maybe.isJust(newRoomName)
  }

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

  fun cancelCreating {
    sequence {
      next {
        newRoomName = Maybe::Nothing
      }
      next {
        aggro = false
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
      name = case(input) {
        Maybe::Just(element) => Dom.getValue(element)
        => ""
      }
      if(name |> String.isBlank) {
        next { aggro = true }
      } else {
        sequence {
          response = Api.createRoom(name)
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
    }
  }

  style createRoom(invert : Bool) {
    if(`#{Maybe.isNothing(newRoomName)} ^ #{invert}`) {
      display: none;
    }
  }

  style roomInput {
    if(aggro) {
      outline: 1px solid red;
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
      <form::createRoom(false) as newRoomForm onSubmit={handleNewRoom}>
        "Name your room: "
        <input::roomInput as input
               value={newRoomName |> Maybe.withDefault("")}
               onInput={updateNewName}
               type="text" />
        <button>"Create"</button>
      </form>
    </div>
  }
}
