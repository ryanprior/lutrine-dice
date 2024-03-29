routes {
  / {
    sequence {
      Application.initialize()
      Realtime.disconnect()
      Application.visitWelcome()
    }
  }

  /room/:id/:name?key=:key (id: String, name: String, key: String) {
    try {
      Application.initialize()
      Application.acceptInvite({room = {id = id, name = name}, key = key})
      Window.navigate("/room/#{id}/#{name}")
      Result::Ok(id)
    }
  }

  /room/:id/:name (id: String, name: String) {
    sequence {
      Application.initialize()
      Messages.loadForRoom(id)
      Characters.loadForRoom(id)
      Application.visitRoom(id)
      Realtime.connect()
      Messages.backfillForRoom(id)
    }
  }
}

component Main {
  connect Theme exposing { theme }
  connect Application exposing { view }

  style app {
    min-height: 100vh;
    background-color: #{theme.interface.background};
    display: flex;
    flex-direction: column;
  }

  style columns {
    justify-content: top;
    flex-direction: row;
    align-items: stretch;
    display: flex;
    flex-grow: 1;
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
            <Chat room={place.room} roomKey={place.key} />
          </>
        }
      </section>
    </div>
  }
}
