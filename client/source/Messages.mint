store Messages {
  state list : Array(Message) = []

  fun update(action : MessageAction.In) {
    next {
      list = list |> Array.push({
        from = action.from,
        parts = action.message
      })
    }
  }
}
