component ConnectionSidebar {
  connect Theme exposing { theme }

  style bar {
    width: 16rem;
    flex-shrink: 0;
    padding: 6px;
    color: #{theme.interface.textColor};
  }

  fun render {
    <section::bar>
      <CharacterList />
    </section>
  }
}
