record Theme.Section {
  textColor : String,
  background : String,
  gutter : String,
  radius : String,
}

record Theme {
  interface : Theme.Section,
  section: Theme.Section,
  chat : Theme.Section,
}

store Theme {
  state theme : Theme = {
    interface = {
      background = "#4A5859",
      textColor = "#E6FDFF",
      gutter = "8px",
      radius = "0px",
    },
    section = {
      background = "rgba(255,255,255,0.1)",
      textColor = "#E6FDFF",
      gutter = "6px",
      radius = "0.33em",
    },
    chat = {
      textColor = "#FCF2EE",
      background = "#32373B",
      gutter = "8px",
      radius = "0px",
    }
  }
}
