store Invite {
  state invites : Map(Room, String) = Map.empty()

  fun fetch {
    case(Application.view) {
      View::Room(roomKey) => try {
        invite = invites |> Map.get(roomKey.room)
        case(invite) {
          Maybe::Just(result) => next {}
            => sequence {
              response = Api.createInvite(roomKey.room.id)
              object = Json.parse(response.body)
                |> Maybe.toResult("")
              data = decode object as RoomKey
              safeName = `encodeURIComponent(#{data.room.name})`
              result = "#{Api.protocol}://#{`window.location.host`}/room/#{data.room.id}/#{safeName}?key=#{data.key}"
              next {
                invites =
                  invites
                  |> Map.set(roomKey.room, result)
              }
            } catch Http.ErrorResponse => error {
              try {
                ({error, "Invite.url Http.ErrorResponse"}) |> Debug.log
                next {}
              }
            } catch Object.Error => error {
              try {
                ({error, "Invite.url Object.Error"}) |> Debug.log
                next {}
              }
            } catch String => error {
              try {
                ({error, "Invite.url String error"}) |> Debug.log
                next {}
              }
            }
        }
      }
        => next {}
    }
  }

  get currentInvite : Maybe(String) {
    case(Application.view) {
      View::Room(roomKey) => invites |> Map.get(roomKey.room)
        => Maybe::Nothing
    }
  }
}

component Invite.Link {
  connect Invite exposing { fetch, currentInvite }
  state open = false

  fun handleInvite(event : Html.Event) {
    sequence {
      event |> Html.Event.preventDefault
      fetch()
      next {
        open = true
      }
    }
  }

  fun highlightInviteInput {
    case(inviteInput) {
      Maybe::Just(element) => `#{element}.select()`
        => next {}
    }
  }

  style invite {
    text-align: right;
    flex-grow: 1;
      & a {
        color: white;
      }
  }

  style invite-link {
    background: rgba(255,255,255,0.5);
    border: 1px solid #9e90a2;
    width: 30rem;
  }

  fun render {
    <>
      <span::invite><a href="#" onClick={handleInvite}>"invite players"</a></span>
      if(open) {
        <Floaty onClose={() {next {open = false}}}>
          <input::invite-link as inviteInput
          type="text"
          readonly={true}
          onClick={highlightInviteInput}
          value={currentInvite |> Maybe.withDefault("")}
          />
        </Floaty>
      }
    </>
  }
}
