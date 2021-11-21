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
  state lastContact : Map(Room, String) = Map.empty()

  fun visitWelcome {
    next {
      view = View::Welcome
    }
  }

  fun findRoomKey(id : String) : Maybe(RoomKey) {
    rooms |> Array.find((key : RoomKey) : Bool { key.room.id == id})
  }

  fun visitRoom(id : String) {
    sequence {
      room = id |> Application.findRoomKey
      case (room) {
        Maybe::Just(room) => next {
          view = View::Room(room)
        }
          => next {}
      }
    }
  }

  fun authRoom(request : Http.Request) : Http.Request {
    try {
      case (view) {
        View::Room(room) => Http.header("Authorization", "Bearer #{room.key}", request)
        => request
      }
    }
  }

  fun initialize {
    sequence {
      loadKeys()
      loadContacts()
    }
  }

  fun recordContact(room : Room, when : String) {
    sequence {
      next {
        lastContact =
          lastContact
          |> Map.set(room, when)
      }
      array = lastContact
        |> Map.entries
        |> Array.map((data : Tuple(Room, String)) { `{room: {id: #{data[0].id}, name: #{data[0].name}}, when: #{data[1]}}` })
        |> Object.Encode.array
      Storage.Local.set(
        "last-contact",
        array |> Json.stringify
      )
    } catch Storage.Error => error {
      Result::Err(error)
    }
  }

  fun loadContacts {
    try {
      data = Storage.Local.get("last-contact")
      object =
        Json.parse(data)
        |> Maybe.toResult("Could not parse last-contact data.")
      array =
        object
        |> Object.Decode.array((object : Object) {
          Result::Ok({
            {
              name = `#{object}.room.name`,
              id = `#{object}.room.id`
            },
            `#{object}.when`
          })
        })
      next {
        lastContact = Map.fromArray(array)
      }
    } catch Storage.Error => error {
      try {
        ({error, "loadContacts Storage.Error"}) |> Debug.log
        next {}
      }
    } catch String => error {
      try {
        ({error, "loadContacts String error"}) |> Debug.log
        next {}
      }
    } catch Object.Error => error {
      try {
        ({error, "loadContacts Object.Error"}) |> Debug.log
        next {}
      }
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
        ({error, "loadKeys Storage.Error"}) |> Debug.log
        next {}
      }
    } catch Object.Error => error {
      sequence {
        ({error, "loadKeys Object.Error"}) |> Debug.log
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
