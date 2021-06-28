enum Message.Part {
  Text(String)
  Rolls(Array(Roll))
}

module Message.Part {
  fun decodeRolls(object : Object) : Result(Object.Error, Message.Part) {
    try {
      rolls = Object.Decode.array(Roll.fromObject, object)
      Result::Ok(Message.Part::Rolls(rolls))
    } catch Object.Error => error {
      Result::Err(error)
    }
  }

  fun fromObject(object : Object) : Result(Object.Error, Message.Part) {
    try {
      `
      typeof #{object} === "string"
        ? #{Result::Ok(Message.Part::Text(`#{object}`))}
        : #{Message.Part.decodeRolls(object)}
      ` as Result(Object.Error, Message.Part)
    }
  }
}

record Message {
  from : Actor,
  parts : Array(Message.Part)
}

component Message {
  property data : Message

  fun render : Html {
    <>
      <{ data.from.name }> ": "
      for (part of data.parts) {
        case (part) {
          Message.Part::Text string => <{ string }>
          Message.Part::Rolls rolls =>
            <>
              for (roll of rolls) {
                <>
                  <{ " " }>
                  <{ roll.dice.count |> Number.toString }><{ "d" }><{ roll.dice.sides |> Number.toString }>
                  <{ " [" }>
                  <{ roll.results |> Array.map(Number.toString) |> String.join(", ") }>
                  <{ "]" }>
                </>
              }
            </>
        }
      }
    </>
  }
}
