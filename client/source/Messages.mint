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
                          constant = 1
                        },
                      results = [14]
                    },
                    {
                      dice =
                        {
                          count = 11,
                          sides = 1,
                          constant = 1
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
                          constant = 1
                        },
                      results = [20]
                    },
                    {
                      dice =
                        {
                          count = 1,
                          sides = 4,
                          constant = 1
                        },
                      results = [2]
                    },
                    {
                      dice =
                        {
                          count = 13,
                          sides = 1,
                          constant = 1
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
                          constant = 1
                        },
                      results = [1]
                    },
                    {
                      dice =
                        {
                          count = 1,
                          sides = 4,
                          constant = 1
                        },
                      results = [4]
                    },
                    {
                      dice =
                        {
                          count = 13,
                          sides = 1,
                          constant = 1
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
                          constant = 1
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
                          constant = 1
                        },
                      results = [6, 1, 1, 2, 6, 3, 1, 1, 4, 6, 5, 6]
                    }
                  ])
              ]
          }
        ])
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
      next {
        list =
          list
          |> Map.set(room, roomMessages)
      }
    }
  }
}
