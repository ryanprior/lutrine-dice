component Top {
  connect Theme exposing { navigation }
  connect Application exposing { view }

  style top-navigation {
    height: 1.5rem;
    padding: 4px 8px;
    margin: 0px;
    color: #{navigation.textColor};
    background-color: #{navigation.background};
    line-height: 1.5rem;
    display: flex;
    flex-direction: row;
    align-items: stretch;
  }

  style logo {
    font-weight: bold;
    color: white;
    text-decoration: none;
  }

  style separator {
    margin-left: 1rem;
    margin-right: 0.5rem;
      &::before {
        font-size: 0.8rem;
        content: "〉";
      }
  }

  style room {
    flex-grow: 0;
    text-decoration: none;
  }

  style invite {
    text-align: right;
    flex-grow: 1;
    & a {
      color: white;
    }
  }

  fun render {
    <section::top-navigation>
      <a::logo href="/">"Lutrine Dice"</a>
      <span::separator />
      <span::room>
        case (view) {
          View::Welcome => "Welcome"
          View::Room(place) => place.room.name
        }
      </span>
      <span::invite><a href="#">"invite players"</a></span>
    </section>
  }
}
