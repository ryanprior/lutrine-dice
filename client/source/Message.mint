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
    `typeof #{object} === "string"
       ? #{Result::Ok(Message.Part::Text(`#{object}`))}
       : #{Message.Part.decodeRolls(object)}
    ` as Result(Object.Error, Message.Part)
  }
}

record Message {
  from : Actor,
  parts : Array(Message.Part)
}

component Message {
  property data : Message

  style results {
      &::before {
        content: "[";
      }
      &::after {
        content: "]";
      }
  }

  style rolls {
    margin: 0px 0.5rem;
      & .roll:not(:first-child)::before {
        content: "+";
      }
  }

  fun renderDie(roll : Roll) : Html {
    <span class="die roll">
      <{ roll.dice.count |> Number.toString }>
      if (roll.dice.sides > 1) {
        <>
          <{ "d" }>
          <span class="sides">
            <{ roll.dice.sides |> Number.toString }>
          </span>
          <span::results>
            <{ roll.results |> Array.map(Number.toString) |> String.join(", ") }>
          </span>
        </>
      }
    </span>
  }

  fun render : Html {
    <>
      <{ data.from.name }> ": "
      for (part of data.parts) {
        case (part) {
          Message.Part::Text string => <{ string }>
          Message.Part::Rolls rolls =>
          <>
            <{ Roll.total(rolls) |> Number.toString }>
            <span::rolls>
              for (roll of rolls) {
                  <{ renderDie(roll) }>
              }
            </span>
          </>
        }
      }
    </>
  }
}
