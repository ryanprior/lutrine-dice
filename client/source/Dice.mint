enum Adjust.Type {
  Low
  High
}

record Adjust {
  sign : Number,
  count : Number,
  type : Adjust.Type
}

record Dice {
  count : Number,
  sides : Number,
  constant : Number,
  adjust : Maybe(Adjust)
}

record Roll {
  dice: Dice,
  results: Array(Number)
}

module Adjust {
  fun fromObject(object : Object) : Result(Object.Error, Adjust) {
    try {
      sign = object |> Object.Decode.field("sign", Object.Decode.number)
      count = object |> Object.Decode.field("count", Object.Decode.number)
      type = case(`#{object}.type`) {
        "low" => Adjust.Type::Low
          => Adjust.Type::High
      }
      Result::Ok({sign = sign, count = count, type = type})
    } catch Object.Error => error {
      try {
        error |> Debug.log
        Result::Err(error)
      }
    }
  }

  fun toObject(adjust : Adjust) : Object {
    try {
      sign = (encode adjust.sign) |> Object.Encode.field("sign")
      count = (encode adjust.count) |> Object.Encode.field("count")
      type = Object.Encode.field("type", `#{adjust.type == Adjust.Type::High} ? "high" : "low"`)
      Object.Encode.object([sign, count, type])
    }
  }
}

module Dice {
  fun fromObject(object : Object) : Result(Object.Error, Dice) {
    try {
      count = object |> Object.Decode.field("count", Object.Decode.number)
      sides = object |> Object.Decode.field("sides", Object.Decode.number)
      constant = object |> Object.Decode.field("constant", Object.Decode.number)
      adjust = if (`!!#{object}.adjust`) {
        try {
          result =
            object
            |> Object.Decode.field("adjust", Adjust.fromObject)
          Maybe::Just(result)
        } catch Object.Error => error {
          try {
            error |> Debug.log
            Maybe::Nothing
          }
        }
      } else {
        Maybe::Nothing
      }
      Result::Ok({count = count, sides = sides, constant = constant, adjust = adjust})
    } catch Object.Error => error {
      try {
        error |> Debug.log
        Result::Err(error)
      }
    }
  }

  fun toObject(dice : Dice) : Object {
    try {
      count = (encode dice.count) |> Object.Encode.field("count")
      sides = (encode dice.sides) |> Object.Encode.field("sides")
      constant = (encode dice.constant) |> Object.Encode.field("constant")
      adjust = case(dice.adjust) {
        Maybe::Just(adjust) => adjust |> Adjust.toObject
        Maybe::Nothing => `null`
      } |> Object.Encode.field("adjust")
      Object.Encode.object([count, sides, constant, adjust])
    }
  }
}

module Roll {
  fun fromObject(object : Object) : Result(Object.Error, Roll) {
    try {
      dice =
        object
        |> Object.Decode.field("dice", Dice.fromObject)
      results =
        object
        |> Object.Decode.field("results", Object.Decode.number |> Object.Decode.array)
      Result::Ok({dice = dice, results = results})
    } catch Object.Error => error {
      Result::Err(error)
    }
  }

  fun toObject(roll : Roll) : Object {
    try {
      dice = roll.dice |> Dice.toObject |> Object.Encode.field("dice")
      results = (encode roll.results) |> Object.Encode.field("results")
      Object.Encode.object([dice, results])
    }
  }

  fun adjustResults(complement : Bool, roll : Roll) : Roll {
    case (roll.dice.adjust) {
      Maybe::Just(adjust) => {
        roll | results = roll.results
          |> Array.sort(
            case (adjust.type) {
              Adjust.Type::High => (a : Number, b : Number) { b - a }
              Adjust.Type::Low => (a : Number, b : Number) { a - b }
            }
          )
          |> if(complement) {
            Array.take(adjust.count)
          } else {
            Array.drop(adjust.count)
          }
      }
        => roll
    }
  }

  fun total(rolls : Array(Roll)) : Number {
    rolls
      |> Array.map(Roll.adjustResults(false))
      |> Array.sumBy((roll : Roll) { roll.dice.constant * (roll.results |> Array.sum) })
  }
}

component DiceRoll {
  property data : Roll
  property showDice = true
  property big = false

  style results {
    display: inline-block;
    background: #9F2D3A;
    border-radius: 0.25rem;
    font-size: 14pt;
    padding: 0px 3px 1px 3px;
    margin: 0px 0.25rem;
    vertical-align: baseline;
  }

  style dropped {
    &:before {
      content: "➖ ";
    }
  }

  style part(constant : Number) {
    line-height: 14pt;
    &:not(:first-child)::before {
      if(constant > 0) {
        content: "+";
        margin: 0px 0px 0px 0.125rem;
      } else {
        content: "-";
        margin: 0px 0.125rem 0px 0.25rem;
      }
    }
  }

  fun render {
    <span::part(dice.constant) class="die roll">
      "#{dice.count}"
      if (dice.sides != 1) {
        <>
          "d#{dice.sides}"
          <Die sides={dice.sides} face={highest} big={big} />
          if(showDice) {
            <>
              case(dice.adjust) {
                Maybe::Just(adjust) =>
                <>
                  <span::results>
                    <{
                      (data |> Roll.adjustResults(false)).results
                        |> Array.map(Number.toString)
                        |> String.join(", ")
                    }>
                  </span>
                  <span::results::dropped>
                    <{
                      (data |> Roll.adjustResults(true)).results
                        |> Array.map(Number.toString)
                        |> String.join(", ")
                    }>
                  </span>
                </>
                Maybe::Nothing =>
                  <span::results>
                  <{ results |> Array.map(Number.toString) |> String.join(", ") }>
                  </span>
              }
            </>
          }
        </>
      }
    </span>
  } where {
    results = data.results
    highest =
      (data |> Roll.adjustResults(false)).results
      |> Array.sort((a : Number, b : Number) { b - a })
      |> Array.at(0)
      |> Maybe.withDefault(0)
    dice = data.dice
  }
}
