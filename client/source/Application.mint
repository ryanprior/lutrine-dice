enum View {
  Welcome
  Room(String)
}

record RoomKey {
  roomId: String,
  key: String
}

store Application {
  state view : View = View::Welcome
  state roomKeys : Array(RoomKey) = []

  fun visit(view : View) {
    next {
      view = view
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
      keys = decode object as Array(RoomKey)
      next {
        roomKeys = keys
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
      data = (encode roomKeys) |> Json.stringify
      Storage.Local.set("room-keys", data)
    }
  }


  fun acceptInvite(id: String, key: String) {
    try {
      next {
        roomKeys = roomKeys |> Array.push({roomId=id, key=key})
      }
      saveKeys()
    }
  }
}
