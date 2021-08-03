require "../base58"
require "db"
require "json"

module Lutrine::Server
  record Room,
         id : String,
         name : String do
    include DB::Serializable
    include JSON::Serializable

    def self.init_schema(db)
      db.exec <<-'SQL'
        CREATE TABLE IF NOT EXISTS "rooms" (
               id TEXT PRIMARY KEY,
               name TEXT NOT NULL
        )
        SQL
      db.exec <<-'SQL'
        CREATE TABLE IF NOT EXISTS "room_keys" (
               room_id INTEGER NOT NULL,
               key TEXT NOT NULL,
               FOREIGN KEY (room_id) REFERENCES rooms (id)
        )
        SQL
      db.exec <<-'SQL'
        CREATE INDEX IF NOT EXISTS "room_key_idx" on room_keys (key)
        SQL
    end

    def key_valid?(key : String, db)
      db.scalar(<<-'SQL', key, id) == 1
        SELECT COUNT(key) FROM room_keys
          JOIN rooms ON room_keys.room_id = rooms.id
          WHERE room_keys.key = ? AND rooms.id = ?
          LIMIT 1
        SQL
    end

    def self.exists?(id : String, db)
      db.query <<-'SQL', id do |result|
        SELECT 1 FROM rooms
          WHERE id = ?
        SQL
        !!result.move_next
      end
    end

    def save(db)
      db.exec <<-'SQL', id, name
        INSERT INTO rooms (id, name)
          VALUES(?, ?)
          ON CONFLICT (id) DO
            UPDATE SET name = excluded.name
        SQL
    end

    def self.new(id : String, db)
      db.query <<-'SQL', id do |result|
        SELECT id, name
          FROM rooms
          WHERE id = ?
        SQL
        if result.move_next
          result.read(Room)
        else nil end
      end
    end

    def create_key(db)
      key = Base58.random 10
      db.exec <<-'SQL', id, key
        INSERT INTO "room_keys"
          VALUES(?, ?);
        SQL
      # handle rejection on primary key uniqueness constraint?
      key
    end
  end
end
