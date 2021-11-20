component Top {
  connect Theme exposing { navigation }
  connect Application exposing { view }
  connect Api exposing { protocol }

  state currentInvite : Maybe(String) = Maybe::Nothing

  style top-navigation {
    height: 1.5rem;
    padding: 4px 8px;
    margin: 0px;
    color: #{navigation.textColor};
    background-color: #{navigation.background};
    line-height: 1.5rem;
    display: flex;
    flex-direction: row;
    align-items: stretch;
  }

  style logo {
    font-weight: bold;
    color: white;
    text-decoration: none;
  }

  style separator {
    margin-left: 1rem;
    margin-right: 0.5rem;
      &::before {
        font-size: 0.8rem;
        content: "〉";
      }
  }

  style room {
    flex-grow: 0;
    text-decoration: none;
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

  fun handleInvite(event : Html.Event) {
    sequence {
      event |> Html.Event.preventDefault
      response = case(view) {
        View::Room(roomKey) => Api.createInvite(roomKey.room.id)
          => `console.log('not in a room')` as Promise(Http.ErrorResponse, Http.Response)
      }
      object = Json.parse(response.body)
        |> Maybe.toResult("")
      data = decode object as RoomKey
      next {
        currentInvite = Maybe::Just("#{protocol}://#{`window.location.host`}/room/#{data.room.id}-#{data.room.name}?key=#{data.key}")
      }
      Result::Ok(response.body)
    } catch Http.ErrorResponse => error {
      try {
        Debug.log(error)
        Result::Err(error)
      }
    } catch Object.Error => error {
      try {
        Debug.log(error)
        Result::Err(error)
      }
    } catch String => error {
      Result::Err(error)
    }
  }

  fun highlightInviteInput {
    case(inviteInput) {
      Maybe::Just(element) => `#{element}.select()`
        => next {}
    }
  }

  fun render {
    <section::top-navigation>
      <a::logo href="/">"Lutrine Dice"</a>
      <span::separator />
      <span::room>
        case (view) {
          View::Welcome => "Welcome"
          View::Room(place) => place.room.name
        }
      </span>
      <span::invite><a href="#" onClick={handleInvite}>"invite players"</a></span>
    <Floaty show={Maybe.isJust(currentInvite)}
            onClose={() { next {currentInvite = Maybe::Nothing} }}>
      <input::invite-link as inviteInput
      type="text"
      readonly={true}
      onClick={highlightInviteInput}
      value={Maybe.withDefault("", currentInvite)}
      />
    </Floaty>
    </section>
  }
}
