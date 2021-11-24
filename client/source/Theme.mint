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
  form : Theme.Section,
}

store Theme {
  state navigation : Theme.Section = {
    background = "rgb(27, 27, 27)",
    textColor = "white",
    gutter = "4px",
    radius = "0px",
  }

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
    },
    form = {
      textColor = "#6d597a",
      background = "#d4cbe5",
      gutter = "3px",
      radius = "0.25em"
    },
  }
}
