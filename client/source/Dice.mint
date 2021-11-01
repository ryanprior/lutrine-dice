record Dice {
  count : Number,
  sides : Number,
  constant : Number,
}

record Roll {
  dice: Dice,
  results: Array(Number)
}

module Roll {
  fun fromObject(object : Object) : Result(Object.Error, Roll) {
    try {
      roll = decode object as Roll
      Result::Ok(roll)
    } catch Object.Error => error {
      Result::Err(error)
    }
  }

  fun total(rolls : Array(Roll)) : Number {
    rolls |> Array.sumBy((roll : Roll) { roll.dice.constant * (roll.results |> Array.sum) })
  }
}

component DiceRoll {
  property data : Roll
  property showDice = true

  style results {
    display: inline-block;
    background: #9F2D3A;
    border-radius: 0.25rem;
    font-size: 14pt;
    padding: 0px 3px 1px 3px;
    margin: 0px 0.25rem;
    vertical-align: baseline;
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
          if(showDice) {
            <span::results>
              <{ results |> Array.map(Number.toString) |> String.join(", ") }>
            </span>
          }
        </>
      }
    </span>
  } where {
    results = data.results
    dice = data.dice
  }
}
