# TODO write documentation for `Server`

require "kemal"
require "./action"

include Lutrine

SOCKETS = Set(HTTP::WebSocket).new

ws "/chat" do |socket|
  SOCKETS.add socket

  socket.on_message do |message|
    p! message
    action = Action.from_json message
    case action
    when MessageAction
      SOCKETS.each(&.send action.roll.to_json)
    else raise NotImplementedError.new action.class
    end
  end

  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
