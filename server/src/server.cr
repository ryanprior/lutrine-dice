# TODO write documentation for `Server`

require "./base58"
require "./flags"
require "./models/action"
require "./models/room"
require "./models/world"
require "kemal"

include Lutrine

WORLD = Server::World.load

def add_cors_headers(env)
  return unless Lutrine::Flags.allow_cors?
  env.response.headers.add("Access-Control-Allow-Origin", "*")
  env.response.headers.add("Access-Control-Allow-Headers", "*")
end

options "/api/room" do |env|
  add_cors_headers env
end

post "/api/room" do |env|
  name = env.params.json["name"].as(String)
  room, key = WORLD.add_room name
  add_cors_headers env
  env.response.content_type = "application/json"
  {room: room, key: key}.to_json
end

ws "/chat/:id" do |socket, ctx|
  room_id = ctx.ws_route_lookup.params["id"]
  key = ctx.request.query_params["key"]
  room = WORLD.room room_id
  WORLD.enter do |db|
    if room.nil? || !room.key_valid? key, db
      socket.close
      next
    end
  end
  WORLD.add_connection socket, room_id

  socket.on_message do |message|
    p! message
    action = Server::Action.from_json message
    case action
    when Server::MessageAction
      roll = action.roll.to_json
      WORLD.broadcast(roll, room_id, action.from.name)
    else raise NotImplementedError.new action.class
    end
  end

  socket.on_close do
    WORLD.disconnect socket
  end
end
