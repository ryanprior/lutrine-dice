record Character {
  name : String
}

store Characters {
  state playerCharacters : Array(Character) = [
    {name = "Gamer"},
    {name = "Player"},
  ]
  state index = 0

  get character : Character {
    Array.at(index, playerCharacters)
      |> Maybe.withDefault({name = "[nobody]"})
  }

  fun select(i : Number) {
    next {
      index = i
    }
  }

  fun add(character : Character) {
    next {
      playerCharacters = playerCharacters |> Array.push(character)
    }
  }

  fun remove(position : Number) {
    sequence {
      if (index >= position && index > 0) {
        next {
          index = index - 1
        }
      } else { next {}}
      next {
        playerCharacters = playerCharacters |> Array.deleteAt(position)
      }
    }
  }

  fun rename(index : Number, newName : String) {
    next {
      playerCharacters =
        playerCharacters
        |> Array.updateAt(index,(character : Character) : Character {
          { character | name = newName }
        })
    }
  }
}

component CharacterList {
  connect Characters exposing { playerCharacters, index, rename, select, add, remove }
  connect Theme exposing { theme }

  style characters {
    background-color: #{theme.section.background};
    border-radius: #{theme.section.radius};
    padding: #{theme.section.gutter};
  }

  fun handleNewCharacter(event : Html.Event) {
    add({name = "New Character"})
  }

  fun handleRemoveCharacter(index : Number, event : Html.Event) {
    remove(index)
  }

  fun render {
    <div::characters>
      "Your characters:"
      <ul>
        <{
          playerCharacters |> Array.mapWithIndex((character : Character, i : Number) : Html {
            <CharacterListItem
              current={i == index}
              data={character}
              rename={rename(i)}
              remove={handleRemoveCharacter(i)}
              select={(event : Html.Event) {
                sequence {
                  event |> Html.Event.preventDefault
                  select(i)
                }
              }} />
          })
        }>
      </ul>
      <button onClick={handleNewCharacter}>"+ character"</button>
    </div>
  }
}

component CharacterListItem {
  property current : Bool
  property data : Character
  property rename : Function(String, Promise(Never, Void))
  property remove : Function(Html.Event, Promise(Never, Void))
  property select : Function(Html.Event, Promise(Never, Void))

  state newName : Maybe(String) = Maybe::Nothing

  use Provider.Keydown {
    keydowns = handleEscape
  } when {
    Maybe.isJust(newName)
  }

  fun handleEscape(event : Html.Event) {
    case (event.key) {
      "Escape" => doneEditing(false, event)
        => next {}
    }
  }

  fun updateNewName(event : Html.Event) {
    next {
      newName = Maybe::Just(Dom.getValue(event.target))
    }
  }

  fun startEditing(event : Html.Event) {
    try {
      event |> Html.Event.preventDefault
      next {
        newName = Maybe::Just(data.name)
      }
      case(input) {
        Maybe::Just(element) => Dom.focusWhenVisible(element)
          => `console.log('nope')` as Promise(String, Void)
      }
    }
  }

  fun doneEditing(save : Bool, event : Html.Event) {
    sequence {
      event |> Html.Event.preventDefault
      case (newName) {
        Maybe::Just(string) => sequence {
          if(save) {
            rename(string)
          } else {
            next {}
          }
          next {
            newName = Maybe::Nothing
          }
        }
          => next {}
      }
    }
  }

  style nameInput {
    if(Maybe.isNothing(newName)) {
      display: none;
    }
  }

  style imageButton {
    background: rgba(255,255,255,0.2);
    width: 1.2em;
    height: 1.2em;
    display: inline-block;
    line-height: 1em;
    vertical-align: baseline;
    text-align: center;
    padding: 1px;
    margin: 0px 1px;
    border-radius: 6px;
    color: white;
    user-select: none;
    text-decoration: none;
      &:visited {
        color: white;
      }
  }

  style item(active : Bool) {
    if(!active) {
      list-style: none;
    }
  }

  style show(active : Bool) {
    if(!active) {
      visibility: hidden;
    }
  }

  fun render {
    <li::item(current)>
      <form::nameInput onSubmit={doneEditing(true)}>
        <input as input
               value={newName |> Maybe.withDefault("")}
               onInput={updateNewName} />
        <input type="submit" value="Done" />
      </form>
      <{ data.name }>
      <a::imageButton::show(!current) href="#" title="play as #{data.name}" onClick={select}>"▶"</a>
      <a::imageButton href="#" title="edit" onClick={startEditing}>"🖉"</a>
      <a::imageButton href="#" title="remove" onClick={remove}><span>"✖"</span></a>
    </li>
  }
}
