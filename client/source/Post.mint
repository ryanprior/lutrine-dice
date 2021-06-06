enum Post.Part {
  Text(String)
  Rolls(Array(Roll))
}

record Post {
  username : String,
  parts : Array(Post.Part)
}

component Post {
  property post : Post

  fun render : Html {
    <li>
      <{ post.username }> ": "
      for (part of post.parts) {
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