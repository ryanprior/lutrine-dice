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
      type = Object.Decode.string(`typeof #{object}`)
      if (type == "string") {
        Result::Ok(Message.Part::Text(`#{object}`))
      } else {
        Message.Part.decodeRolls(object)
      }
    } catch Object.Error => error {
      Result::Err(error)
    }
  }
  fun toObject(part : Message.Part) : Object {
    try {
      case(part) {
        Message.Part::Text(string) => `#{string}`
        Message.Part::Rolls(rolls) => rolls |> Array.map(Roll.toObject) |> Object.Encode.array
      }
    }
  }
}

record Message {
  from : Actor,
  parts : Array(Message.Part)
}

module Message {
  fun fromObject(object : Object) : Result(Object.Error, Message) {
    try {
      from = Actor.fromObject(whomst)
      message = Object.Decode.array(Message.Part.fromObject, parts)
      Result::Ok({
        from = from,
        parts = message
      })
    } catch Object.Error => error {
      Result::Err(error)
    }
  } where {
    whomst = `#{object}.from`
    parts = `#{object}.parts`
  }
  fun toObject(message : Message) : Object {
    `{
      from: #{Actor.toObject(message.from)},
      parts: #{Object.Encode.array(message.parts |> Array.map(Message.Part.toObject))}
    }`
  }
}

component MessageDisplay {
  property data : Message
  property first : Bool
  property mostRecent : Bool

  style total {
    display: inline-block;
    background: #F4B860;
    color: #32373B;
    border-radius: 0.25rem;
    font-size: 14pt;
    padding: 0px 3px 0px 3px;
    margin: 0px 0.25rem;
    vertical-align: baseline;
    min-width: 1.5rem;
    text-align: center;
  }

  style sender {
    line-height: 22pt;
    font-size: 0.8rem;
    font-weight: bold;
    align-self: end;
    padding: 0.125rem 0.5rem 0.125rem 0px;
    word-break: break-word;
    grid-column: span 2;
    if(!first) {
      display: none;
    }
  }

  style message {
    line-height: 22pt;
    align-self: end;
    padding: 0.125rem 0px;
  }

  style roll {
    break-inside: avoid;
    display: inline-block;
    font-weight: bold;
    font-variant-numeric: lining-nums;
  }

  fun complex(rolls : Array(Roll)) : Bool {
    (rolls |> Array.size) > 1 || (rolls |> Array.any((roll : Roll) { roll.dice.count > 1 }))
  }

  fun render {
    <>
      <div::sender class="whomst"><{ data.from.name }></div>
      <span></span>
      <div::message>
        for (part of data.parts) {
          case (part) {
            Message.Part::Text(string) => <{ string }>
            Message.Part::Rolls(rolls) =>
              <span::roll>
                <{rolls |> Array.map((roll : Roll) : Html {
                  <DiceRoll data={roll} showDice={rolls |> complex} big={mostRecent} />
                })}>
                if(rolls |> complex) {
                  " = "
                }
                <span::total><{ Roll.total(rolls) |> Number.toString }></span>
              </span>
          }
        }
      </div>
    </>
  }
}
