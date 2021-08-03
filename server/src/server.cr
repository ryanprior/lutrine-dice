# TODO write documentation for `Server`

require "./action"
require "./base58"
require "./models/room"
require "./models/world"
require "kemal"
require "kemal-session"

include Lutrine

WORLD = Server::World.load

# get "/room/:id-:name" do |env|
#   name, id = env.params.url.select("name", "id").values
#   halt env, status_code: 404, response: "Room not found" unless WORLD.rooms.has_key? id

#   if(env.params.query.has_key? "key")
#     key = env.params.query["key"]
#     room = WORLD.room(id)
#     WORLD.enter do |db|
#       halt env, status_code: 403, response: "Unauthorized" unless room.key_valid? key, db
#     end
#     # connection = env.session.object?("connection") || Server::Connection.new
#     # env.session.object("connection", connection.copy_with rooms: connection.rooms.add(id))
#     env.redirect "/room/#{id}-#{name}"
#   else
#     send_file env, ENV["DIST_DIR"]+"/index.html"
#   end
# end

def add_cors_headers(env)
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
    p! room, room && room.key_valid?(key, db)
    socket.close unless room && room.key_valid? key, db
  end
  # TODO check correctness of room key
  # TODO handle keys for multiple rooms (JSON cookie?)

  WORLD.add_connection socket, room_id

  socket.on_message do |message|
    p! message
    action = Action.from_json message
    case action
    when MessageAction
      WORLD.broadcast(action.roll.to_json, room_id)
    else raise NotImplementedError.new action.class
    end
  end

  socket.on_close do
    WORLD.disconnect socket
  end
end
