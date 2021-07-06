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
}

record Message {
  from : Actor,
  parts : Array(Message.Part)
}

component Message {
  property data : Message

  style total {
    display: inline-block;
    background: #F4B860;
    color: #32373B;
    border-radius: 0.25rem;
    font-size: 14pt;
    font-weight: bold;
    padding: 0px 3px 1px 3px;
    margin: 0px 0.25rem;
    vertical-align: baseline;
    min-width: 1.5rem;
    text-align: center;
  }

  style sender {
    line-height: 22pt;
    align-self: end;
    padding: 0.125rem 0.5rem 0.125rem 0px;
    border-bottom: 1px dotted #495057;
    word-break: break-word;
  }

  style message {
    line-height: 22pt;
    align-self: end;
    border-bottom: 1px dotted #495057;
    padding: 0.125rem 0px;
  }

  style roll {
    break-inside: avoid;
    display: inline-block;
  }

  fun complex(rolls : Array(Roll)) : Bool {
    (rolls |> Array.size) > 1 || (rolls |> Array.any((roll : Roll) { roll.dice.count > 1 }))
  }

  fun render : Html {
    <>
      <span::sender><{ data.from.name }></span>
      <span::message>
        for (part of data.parts) {
          case (part) {
            Message.Part::Text(string) => <{ string }>
              Message.Part::Rolls(rolls) =>
            <span::roll>
              for (roll of rolls) {
                <DiceRoll data={roll} showDice={rolls |> complex} />
              }
              if(rolls |> complex) {
                  <{ " = "}>
              }
              <span::total><{ Roll.total(rolls) |> Number.toString }></span>
            </span>
          }
        }
      </span>
    </>
  }
}
