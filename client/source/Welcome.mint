component Welcome {
  connect Theme exposing { theme }

  style app {
    min-width: 18rem;
    min-height: 38rem;
    color: #{theme.interface.textColor};
    background: #{theme.interface.background};
    border: 1px solid rgba(255,255,255,0.6);
    border-radius: 1rem;
    padding: 1.5rem;
  }

  fun render : Html {
    <div::app>
      "Hello!"
      <a href="room/test">"Enter test room"</a>
    </div>
  }
}
