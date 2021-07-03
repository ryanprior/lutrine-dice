component Main {
  style app {
    justify-content: top;
    flex-direction: column;
    align-items: center;
    display: flex;

    background-color: #4A5859;
    min-height: 100vh;

    font-family: Open Sans;
    font-weight: bold;
  }

  fun render : Html {
    <div::app>
      <Chat />
    </div>
  }
}
