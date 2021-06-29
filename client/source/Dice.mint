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
    rolls |> Array.sumBy((roll : Roll) : Number { roll.results |> Array.sum })
  }
}
