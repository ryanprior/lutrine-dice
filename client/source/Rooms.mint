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

  style title {
    margin-bottom: 0px;
  }

  style description {
    font-size: 10pt;
    color: #b6c2d9;
    margin-bottom: 0.5rem;
  }

  style createRoom(invert : Bool) {
    if(`#{Maybe.isNothing(newRoomName)} ^ #{invert}`) {
      display: none;
    }
    background: #{theme.form.background};
    color: #{theme.form.textColor};
    display: inline-block;
    margin-top: #{theme.section.gutter};
    padding: #{theme.section.radius};
    border-radius: #{theme.section.radius};
    min-height: 1.6rem;
    line-height: 1.6rem;
    vertical-align: middle;

    &[data-role="create-room"] {
      color: #6d597a;
    }

    & button {
      background: #{theme.form.textColor};
      color: #{theme.form.background};
      border: none;
      border-radius: #{theme.form.radius};
      padding: 2.5px 3.5px;
    }
  }

  style roomInput {
    if(aggro) {
      outline: 1px solid red;
    } else {
      outline: default;
    }
    margin-right: #{theme.form.gutter};
  }

  style formDesc {
    font-size: 7pt;
    line-height: initial;
    font-weight: 600;
  }

  fun render {
    <div::rooms id="rooms">
      <h2::title>"Your Games"</h2>
      <div::description>
        if(Array.size(data) > 0) {
          <{"rooms you created or joined"}>
        } else {
          <>
            "create a room to begin! ✨"
            <br />
            "then you can invite friends and rivals"
          </>
        }
      </div>
      <ul>
        for (roomKey of data) {
          <li><a href="/room/#{roomKey.room.id}/#{roomKey.room.name}"><{ roomKey.room.name }></a></li>
        }
      </ul>
      <a::createRoom(true) data-role="create-room" href="#" onClick={startCreating}>"+ Create new"</a>
      <form::createRoom(false) as newRoomForm onSubmit={handleNewRoom}>
        <div::formDesc>"Game name"</div>
        <input::roomInput as input
               data-role="new-room-name"
               value={newRoomName |> Maybe.withDefault("")}
               onInput={updateNewName}
               type="text" />
        <button>"Create"</button>
      </form>
    </div>
  }
}
