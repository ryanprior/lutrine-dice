record Message {
  username : String,
  text : String
}

store Messages {
  state list : Array(Message) = []

    fun add(message : Message) {
    next {
        list = list |> Array.push(message)
    }
  }
}
