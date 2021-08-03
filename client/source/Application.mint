enum View {
  Welcome
  Room(RoomKey)
}

record Room {
  id: String,
  name: String,
}

record RoomKey {
  room: Room,
  key: String,
}

store Application {
  state view : View = View::Welcome
  state rooms : Array(RoomKey) = []

  fun visitWelcome {
    next {
      view = View::Welcome
    }
  }

  fun visitRoom(id : String) {
    sequence {
      room = rooms |> Array.find((key : RoomKey) : Bool { key.room.id == id })
      case (room) {
        Maybe::Just(room) => next {
          view = View::Room(room)
        }
          => next {}
      }
    }
  }

  fun initialize {
    sequence {
      loadKeys()
    }
  }

  fun loadKeys {
    try {
      data = Storage.Local.get("room-keys")
      object =
        Json.parse(data)
        |> Maybe.toResult("")
      loadedRooms = decode object as Array(RoomKey)
      next {
        rooms = loadedRooms
      }
    } catch Storage.Error => error {
      sequence {
        Debug.log(error)
        next {}
      }
    } catch Object.Error => error {
      sequence {
        Debug.log(error)
        next {}
      }
    } catch String => error {
      next {}
    }
  }

  fun saveKeys {
    try {
      data = (encode rooms) |> Json.stringify
      Storage.Local.set("room-keys", data)
    }
  }


  fun acceptInvite(key: RoomKey) {
    try {
      next {
        rooms = rooms |> Array.push(key)
      }
      saveKeys()
    }
  }
}
