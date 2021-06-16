enum Message.Part {
  Text(String)
  Rolls(Array(Roll))
}

record Message {
  from : Actor,
  parts : Array(Message.Part)
}

component Message {
  property data : Post

  fun render : Html {
    <li>
      <{ data.from.name }> ": "
      for (part of data.parts) {
        case (part) {
          Post.Part::Text string => <{ string }>
          Post.Part::Rolls rolls =>
            <span>
              for (roll of rolls) {
                <span>
                  <{ " " }>
                  <{ roll.dice.count |> Number.toString }><{ "d" }><{ roll.dice.sides |> Number.toString }>
                  <{ " [" }>
                  <{ roll.results |> Array.map(Number.toString) |> String.join(", ") }>
                  <{ "]" }>
                </span>
              }
            </span>
        }
      }
    </li>
  }
}
