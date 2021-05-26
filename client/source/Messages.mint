record Message {
  text : String
}

store Messages {
  state list : Array(Message) = []

  fun add(msg: String) {
    next {
      list = list |> Array.push({text=msg})
    }
  }
}
