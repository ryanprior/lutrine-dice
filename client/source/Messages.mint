store Messages {
  state list : Map(Room, Array(Message)) = Map.empty()

  fun populateTestMessages(room : Room) {
    next {
      list = list
        |> Map.set(room, [
          {
            from = { name = "TomBombadil" },
            parts = [Message.Part::Text("Hey dol! merry dol! ring a dong dillo!")]
          },
          {
            from = { name = "Gimli" },
            parts =
              [
                Message.Part::Text("Axe attack: "),
                Message.Part::Rolls(
                  [
                    {
                      dice =
                        {
                          count = 1,
                          sides = 20,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [14]
                    },
                    {
                      dice =
                        {
                          count = 11,
                          sides = 1,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [11]
                    }
                  ])
              ]
          },
          {
            from = { name = "Legolas" },
            parts =
              [
                Message.Part::Text("First arrow "),
                Message.Part::Rolls(
                  [
                    {
                      dice =
                        {
                          count = 1,
                          sides = 20,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [20]
                    },
                    {
                      dice =
                        {
                          count = 1,
                          sides = 4,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [2]
                    },
                    {
                      dice =
                        {
                          count = 13,
                          sides = 1,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [13]
                    }
                  ]),
                Message.Part::Text(" and then another arrow "),
                Message.Part::Rolls(
                  [
                    {
                      dice =
                        {
                          count = 1,
                          sides = 20,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [1]
                    },
                    {
                      dice =
                        {
                          count = 1,
                          sides = 4,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [4]
                    },
                    {
                      dice =
                        {
                          count = 13,
                          sides = 1,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [13]
                    }
                  ])
              ]
          },
          {
            from = { name = "TomBombadil" },
            parts = [Message.Part::Text("Ring a dong! hop along! fal lal the willow!")]
          },
          {
            from = { name = "Legolas" },
            parts =
              [
                Message.Part::Text("Pratfall? "),
                Message.Part::Rolls(
                  [
                    {
                      dice =
                        {
                          count = 1,
                          sides = 20,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [1]
                    }
                  ])
              ]
          },
          {
            from = { name = "TomBombadil" },
            parts = [Message.Part::Text("Tom Bom, jolly Tom, Tom Bombadillo!")]
          },
          {
            from = { name = "Eye of Sauron" },
            parts =
              [
                Message.Part::Text("FIRE DAMAGE "),
                Message.Part::Rolls(
                  [
                    {
                      dice =
                        {
                          count = 12,
                          sides = 6,
                          constant = 1,
                          adjust = Maybe::Nothing
                        },
                      results = [6, 1, 1, 2, 6, 3, 1, 1, 4, 6, 5, 6]
                    }
                  ])
              ]
          }
        ])
    }
  }

  fun loadForRoom (id : String) {
    try {
      key =
        Application.findRoomKey(id)
        |> Maybe.toResult("No such room")
      data = Storage.Local.get("messages-#{key.room.id}")
      object =
        Json.parse(data)
        |> Maybe.toResult("Decode Error")
      roomMessages = object |> Object.Decode.array(Message.fromObject)
      next {
        list =
          list
          |> Map.set(key.room, roomMessages)
      }
    } catch Object.Error => error {
      sequence {
        error |> Debug.log
        next {}
      }
    } catch Storage.Error => error {
      sequence {
        error |> Debug.log
        next {}
      }
    } catch String => error {
      sequence {
        error |> Debug.log
        next {}
      }
    }
  }

  fun backfillForRoom (id : String) {
    sequence {
      key =
        Application.findRoomKey(id)
        |> Maybe.toResult("No such room")
      lastContact =
        Application.lastContact
        |> Map.get(key.room)
        |> Maybe.withDefault("0")
      response = Api.messageHistory(id, lastContact)
      object =
        Json.parse(response.body)
        |> Maybe.toResult("Could not parse message JSON")
      messages =
        object
        |> Object.Decode.array(MessageAction.In.fromObject)
      for (message of Array.reverse(messages)) {
        update(message, key.room)
      }
      next {}
    } catch Object.Error => error {
      sequence {
        error |> Debug.log
        next {}
      }
    } catch Http.ErrorResponse => error {
      sequence {
        error |> Debug.log
        next {}
      }
    } catch String => error {
      sequence {
        error |> Debug.log
        next {}
      }
    }
  }

  fun update (action : MessageAction.In, room : Room) {
    try {
      roomMessages =
        list
        |> Map.get(room)
        |> Maybe.withDefault([])
        |> Array.push(
          {
            from = action.from,
            parts = action.message
          })
      array =
        roomMessages
        |> Array.map(Message.toObject)
        |> Object.Encode.array
      Storage.Local.set(
        "messages-#{room.id}",
        array |> Json.stringify
      )
      Application.recordContact(room, action.serverTime)
      next {
        list =
          list
          |> Map.set(room, roomMessages)
      }
    } catch Storage.Error => err {
      sequence {
        err |> Debug.log
        next {}
      }
    }
  }
}
