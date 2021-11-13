# TODO write documentation for `Server`

require "./flags"
require "./models/action"
require "./models/room"
require "./models/world"
require "./models/memo"
require "kemal"

include Lutrine

WORLD = Server::World.load

def add_cors_headers(env)
  return unless Lutrine::Flags.allow_cors?
  env.response.headers.add("Access-Control-Allow-Origin", "*")
  env.response.headers.add("Access-Control-Allow-Headers", "*")
end

# Redirect root or room URLs to index.html
get "/" do |env|
  send_file env, "public/index.html"
end

get "/room/:id-:name" do |env|
  send_file env, "public/index.html"
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

options "/api/room/:id/invite" do |env|
  add_cors_headers env
end

post "/api/room/:id/invite" do |env|
  id = env.params.url["id"]
  token = env.request.headers["Authorization"].split[1]
  room = WORLD.room(id) || halt(env, status_code: 404, response: "Room not found")
  WORLD.enter do |db|
    halt(env, status_code: 403, response: "Forbidden") unless room.key_valid? token, db
    key = room.create_key db
    add_cors_headers env
    env.response.content_type = "application/json"
    {room: room, key: key}.to_json
  end
end

options "/api/room/:id/history" do |env|
  add_cors_headers env
end

get "/api/room/:id/history" do |env|
  id = env.params.url["id"]
  auth_header = env.request.headers["Authorization"] || halt(env, status_code: 401, response: "Unauthorized")
  token = auth_header.split[1]
  since = env.params.url.fetch("since", "0")
  room = WORLD.room(id) || halt(env, status_code: 404, response: "Room not found")
  WORLD.enter do |db|
    halt(env, status_code: 403, response: "Forbidden") unless room.key_valid? token, db
    messages = Server::Memo.messages_for id, since, db
    message_actions = messages.map do |msg|
      Server::MessageAction.from_json msg.message
    end
    add_cors_headers env
    env.response.content_type = "application/json"
    message_actions.to_json
  end
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
    Log.info { message }
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
