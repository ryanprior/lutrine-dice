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
  serverTime : String,
  message : Array(Message.Part)
}

module Actor {
  fun fromObject(object : Object) : Result(Object.Error, Actor) {
    try {
      name = Object.Decode.field("name", Object.Decode.string, object)
      Result::Ok({
        name = name
      })
    } catch Object.Error => error {
      Result::Err(error)
    }
  }
  fun toObject(actor : Actor) : Object {
    `{name: #{actor.name}}`
  }
}

module MessageAction.In {
  fun fromObject(object: Object) : Result(Object.Error, MessageAction.In) {
    try {
      type = Object.Decode.field("type", Object.Decode.string, object)
      from = Actor.fromObject(whomst)
      message = Object.Decode.array(Message.Part.fromObject, parts)
      Result::Ok({
        type = type,
        from = from,
        serverTime = time,
        message = message
      })
    } catch Object.Error => error {
      Result::Err(error)
    }
  } where {
    whomst = `#{object}.from`
    parts = `#{object}.message`
    time = `#{object}.serverTime`
  }
}
