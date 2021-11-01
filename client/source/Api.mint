store Api {
  state endpoint = "localhost:3000"
  state secure = false

  get protocol {
    if(secure) {
      "https"
    } else {
      "http"
    }
  }

  get base {
    "#{protocol}://#{endpoint}"
  }

  fun createRoom(name : String) {
    "#{base}/api/room"
      |> Http.post
      |> Http.jsonBody(encode {name = Debug.log(name)})
      |> Http.send
  }
}
