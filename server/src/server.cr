# TODO: Write documentation for `Server`

require "kemal"
require "./dice"

include Lutrine::Dice

SOCKETS = Set(HTTP::WebSocket).new

ws "/chat" do |socket|
  SOCKETS.add socket

  socket.on_message do |message|
    p! message
    dice_msg = Lutrine::Dice.roll_message Reader.read(message)
    SOCKETS.each(&.send dice_msg.to_s)
  end

  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
