store Api {
  state endpoint = @ENDPOINT
  state secure = `window.location.protocol === "https:"` as Bool

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
      |> Http.jsonBody(encode {name = name})
      |> Http.send
  }

  fun createInvite(roomId : String) {
    "#{base}/api/room/#{roomId}/invite"
      |> Http.post
      |> Application.authRoom
      |> Http.send
  }

  fun messageHistory(roomId : String, since : String) {
    "#{base}/api/room/#{roomId}/history?since=#{since}"
      |> Http.get
      |> Application.authRoom
      |> Http.send
  }
}
