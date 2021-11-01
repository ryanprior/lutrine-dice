routes {
  / {
    sequence {
      Application.initialize()
      Application.visitWelcome()
    }
  }

  /room/:id-:name?key=:key (id: String, name: String, key: String) {
    try {
      Application.initialize()
      Application.acceptInvite({room = {id = id, name = name}, key = key})
      Window.navigate("/room/#{id}-#{name}")
      Result::Ok(id)
    } catch Storage.Error => error {
      Result::Err(error)
    }
  }

  /room/:id-:name (id: String, name: String) {
    sequence {
      Application.initialize()
      Application.visitRoom(id)
    }
  }
}

component Main {
  connect Theme exposing { theme }
  connect Application exposing { view }

  style app {
    min-height: 100vh;
    background-color: #{theme.interface.background};
  }

  style columns {
    justify-content: top;
    flex-direction: row;
    align-items: stretch;
    display: flex;
  }

  fun render {
    <div::app>
      <Top />
      <section::columns>
        case (view) {
          View::Welcome => <Welcome />
          View::Room(place) =>
          <>
            <ConnectionSidebar />
            <Chat room={place.room.id} roomKey={Debug.log(place.key)} />
          </>
        }
      </section>
    </div>
  }
}
