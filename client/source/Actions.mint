record Actor {
  name : String
}

record MessageAction.Out {
  type : String,
  from : Actor,
  message : String
}

record MessageAction.In {
  type : String,
  from : Actor,
  message : Array(Message.Part)
}
