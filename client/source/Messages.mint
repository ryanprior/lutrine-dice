store Messages {
  state list : Array(Message) = []

  fun update(action : MessageAction.In) : Promise(Never, Void) {
    sequence {
      next {
        list = list |> Array.push({
          from = action.from,
          parts = action.message
        })
      }
    }
  }
}
