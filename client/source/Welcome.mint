component Welcome {
  connect Theme exposing { theme }
  connect Application exposing { rooms }

  style welcome {
    min-width: 18rem;
    margin: #{theme.section.gutter};
    color: #{theme.section.textColor};
    background: #{theme.section.background};
    border-radius: #{theme.section.radius};
    padding: 1.5rem;
  }

  fun render : Html {
    <div::welcome>
      "Welcome to Lutrine Dice!"
      <br />
      <Rooms data={rooms} />
    </div>
  }
}
