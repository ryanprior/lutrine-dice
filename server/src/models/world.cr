require "../base58"
require "./room"
require "./memo"
require "db"
require "kemal"
require "sqlite3"

module Lutrine::Server
  DB_FILE = ENV.fetch("LUTRINE_DB", "sqlite3:./lutrine-dice.db")

  record Connection, socket : HTTP::WebSocket, room : Room

  record World,
         connections : Hash(HTTP::WebSocket, Connection),
         rooms : Hash(String, Room) do

    def self.load
      DB.open DB_FILE do |db|
        Room.init_schema db
        Memo::Message.init_schema db
        new connections: Hash(HTTP::WebSocket, Connection).new, rooms: Hash(String, Room).new
      end
    end

    def room(id)
      return rooms[id] if rooms.includes? id
      enter do |db|
        room = Room.new(id, db)
        case room
        when Room then rooms[id] ||= room
        when Nil then nil
        end
      end
    end

    def add_room(name)
      enter do |db|
        id = Base58.random(8)
        room = Room.new id: id, name: name
        room.save(db)
        key = room.create_key(db)
        rooms[id] = room
        return room, key
      end
    end

    def add_connection(socket, room_id)
      room = room(room_id)
      case room
      when Room then connections[socket] = Connection.new socket: socket, room: room
      when Nil then nil
      end
    end

    def broadcast(message, room_id, from)
      connections.values.select(&.room.id.== room_id).each(&.socket.send message)
      enter do |db|
        memo = Server::Memo::Message.new id: nil,
                                         room_id: room_id,
                                         from: from,
                                         message: message
        memo.save(db)
      end
    end

    def disconnect(socket)
      connections.delete socket
    end

    def enter(&)
      DB.open DB_FILE do |db|
        yield(db)
      end
    end
  end
end
