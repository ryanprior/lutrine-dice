require "db"
require "./action"

module Lutrine::Server::Memo
  record Message, id : Int64?, room_id : String, from : String, message : String do
    include DB::Serializable

    def self.init_schema(db)
      db.exec <<-'SQL'
        CREATE TABLE IF NOT EXISTS "messages" (
               "id" INTEGER PRIMARY KEY,
               "room_id" TEXT NOT NULL,
               "from" TEXT NOT NULL,
               "message" TEXT NOT NULL,
               FOREIGN KEY (room_id) REFERENCES rooms (id)
        )
        SQL
      db.exec %|CREATE INDEX IF NOT EXISTS "room_messages_idx" ON messages (room_id)|
    end

    def save(db)
      if id.nil?
        db.exec %|INSERT INTO messages ("room_id", "from", "message") VALUES (?, ?, ?)|,
                room_id, from, message
      else
        db.exec <<-'SQL', room_id, from, message, id
        UPDATE messages SET
          "room_id" = ?,
          "from" = ?,
          "message" = ?
        WHERE id = ?
        SQL
      end
    end
  end

  def self.messages_for(room_id : String, db, limit = 1000)
    messages = Array(Message).new
    db.query <<-'SQL', room_id, limit do |result|
      SELECT "from", "message", "room_id"
        FROM messages
        WHERE room_id = ?
        LIMIT ?
      SQL
      result.each do
        messages << result.read(Message)
      end
    end
    messages
  end
end
