store Api {
  state endpoint = "localhost:3000"
  state secure = false

  get wsProtocol {
    if(secure) {
      "wss"
    } else {
      "ws"
    }
  }

  get protocol {
    if(secure) {
      "https"
    } else {
      "http"
    }
  }

  get ws {
    "#{wsProtocol}://#{endpoint}"
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
