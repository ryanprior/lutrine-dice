# TODO: Write documentation for `Server`

require "kemal"

SOCKETS = Set(HTTP::WebSocket).new

ws "/chat" do |socket|
  SOCKETS.add socket

  socket.on_message do |message|
    p! message
    SOCKETS.each(&.send message)
  end

  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
