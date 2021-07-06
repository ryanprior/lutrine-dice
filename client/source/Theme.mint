record Theme.Section {
  textColor : String,
  background : String,
}

record Theme {
  interface : Theme.Section,
  chat : Theme.Section,
}

store Theme {
  state theme : Theme = {
    interface = {
      background = "#4A5859",
      textColor = "#E6FDFF",
    },
    chat = {
      textColor = "#FCF2EE",
      background = "#32373B",
    }
  }
}
