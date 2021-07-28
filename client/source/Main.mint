routes {
  / {
    sequence {
      Application.initialize()
      Application.visit(View::Welcome)
    }
  }

  /room/:id?key=:key (id: String, key: String) {
    try {
      Application.initialize()
      Application.acceptInvite(id, key)
      Window.navigate("/room/#{id}")
      Result::Ok(id)
    } catch Storage.Error => error {
      Result::Err(error)
    }
  }

  /room/:id (id: String) {
    sequence {
      Application.initialize()
      Application.visit(View::Room(id))
    }
  }
}

component Main {
  connect Theme exposing { theme }
  connect Application exposing { view }

  style app {
    height: 100vh;
    width: 100vw;
    justify-content: top;
    flex-direction: row;
    align-items: stretch;
    display: flex;

    background-color: #{theme.interface.background};
    min-height: 100vh;
  }

  fun render : Html {
    <div::app>
      case (view) {
        View::Welcome => <Welcome />
        View::Room(id) =>
          <>
            <ConnectionSidebar />
            <Chat room={id} />
          </>
      }
    </div>
  }
}
