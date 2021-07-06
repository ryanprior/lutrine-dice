component Main {
  connect Theme exposing { theme }

  style app {
    height: 100vh;
    width: 100vw;
    justify-content: top;
    flex-direction: row;
    align-items: stretch;
    display: flex;

    background-color: #{theme.interface.background};
    min-height: 100vh;
  }

  fun render : Html {
    <div::app>
      <ConnectionSidebar />
      <Chat />
    </div>
  }
}
