record Character {
  name : String
}

store Characters {
  state playerCharacters : Map(Room, Array(Character)) = Map.empty()
  state indexes : Map(Room, Number) = Map.empty()

  get roomCharacters : Array(Character) {
    case(Application.view) {
      View::Room(key) => playerCharacters
        |> Map.get(key.room)
        |> Maybe.withDefault([])
        => []
    }
  }

  get index : Number {
    case(Application.view) {
      View::Room(key) => indexes
        |> Map.get(key.room)
        |> Maybe.withDefault(0)
        => 0
    }
  }

  get character : Character {
    Array.at(index, roomCharacters)
      |> Maybe.withDefault({name = "[nobody]"})
  }

  fun select(i : Number) {
    case (Application.view) {
      View::Room(key) => next {
        indexes =
          indexes
          |> Map.set(key.room, i)
      }
        => next {}
    }
  }

  fun loadForRoom(id : String) {
    try {
      room = Application.findRoomKey(id)
      case(room) {
        Maybe::Just(key) => try {
          data = Storage.Local.get("characters-#{key.room.id}")
          object =
            Json.parse(data)
            |> Maybe.toResult("Decode Error")
          characters =
            object
            |> Object.Decode.array(Actor.fromObject)
          next {
            playerCharacters =
              playerCharacters
              |> Map.set(key.room, characters)
          }
        } catch Object.Error => error {
          sequence {
            error |> Debug.log
            next {}
          }
        } catch Storage.Error => error {
          sequence {
            error |> Debug.log
            next {}
          }
        } catch String => error {
          sequence {
            error |> Debug.log
            next {}
          }
        }
          => next {}
      }
    }
  }

  fun persist(room : Room) {
    try {
      array =
        playerCharacters
        |> Map.get(room)
        |> Maybe.withDefault([])
        |> Array.map(Actor.toObject)
        |> Object.Encode.array
      Storage.Local.set(
        "characters-#{room.id}",
        array |> Json.stringify
      )
    }
  }

  fun add(character : Character) {
    case (Application.view) {
      View::Room(key) => try {
        next {
          playerCharacters =
            playerCharacters
            |> Map.set(key.room, newCharacters)
        }
        persist(key.room)
        next {}
      } catch Storage.Error => error {
        try {
          Debug.log(error)
          next {}
        }
      }
        => next {}
    }
  } where {
    newCharacters =
      roomCharacters
      |> Array.push(character)
  }

  fun remove(position : Number) {
    case (Application.view) {
      View::Room(key) => try {
        if (index >= position && index > 0) {
          next {
            indexes =
              indexes
              |> Map.set(key.room, index - 1)
          }
        } else { next {} }
        next {
          playerCharacters =
            playerCharacters
            |> Map.set(key.room, newCharacters)
        }
        persist(key.room)
        next {}
      } catch Storage.Error => error {
        try {
          Debug.log(error)
          next {}
        }
      }
        => next {}
    }
  } where {
    newCharacters =
      roomCharacters
      |> Array.deleteAt(position)
  }

  fun rename(index : Number, newName : String) {
    case (Application.view) {
      View::Room(key) => try {
        next {
          playerCharacters =
            playerCharacters
            |> Map.set(key.room, newCharacters)
        }
        persist(key.room)
        next {}
      } catch Storage.Error => error {
        try {
          Debug.log(error)
          next {}
        }
      }
        => next {}
    }
  } where {
    newCharacters =
      roomCharacters
      |> Array.updateAt(index,(character : Character) : Character {
        { character | name = newName }
      })
  }
}

component CharacterList {
  connect Characters exposing { roomCharacters, index, rename, select, add, remove }
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
          roomCharacters |> Array.mapWithIndex((character : Character, i : Number) : Html {
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
