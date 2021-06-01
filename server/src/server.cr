# TODO: Write documentation for `Server`

require "kemal"
require "./dice"

SOCKETS = Set(HTTP::WebSocket).new

ws "/chat" do |socket|
  SOCKETS.add socket

  socket.on_message do |message|
    p! message
    dice_msg = DiceReader.read(message).to_s
    SOCKETS.each(&.send message)
    SOCKETS.each(&.send dice_msg)
  end

  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
