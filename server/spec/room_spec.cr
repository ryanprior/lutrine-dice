require "./spec_helper"

include Lutrine::Server

world = World.load
test_data = {room: "40376ffc"}
test_key = ""

describe Room, tags: "model" do
  describe "#save" do
    it "saves a room to the database" do
      world.enter do |db|
        Room.new(id: test_data[:room], name: "test").save(db).should_not be_nil
      end
    end
  end
  describe "#exists?" do
    it "reports that a room does not exist" do
      world.enter do |db|
        result = Room.exists? "not-exist", db
        result.should be_false
      end
    end
    it "reports that a room does exist" do
      world.enter do |db|
        result = Room.exists? test_data[:room], db
        result.should be_true
      end
    end
  end
  describe "#create_key" do
    it "creates a new room key" do
      world.enter do |db|
        result = world.room(test_data[:room]).not_nil!.create_key(db)
        result.size.should be >= 10
        test_key = result
      end
    end
  end
  describe "#key_valid?" do
    it "accepts valid keys" do
      world.enter do |db|
        result = world.room(test_data[:room]).not_nil!.key_valid? test_key, db
        result.should be_true
      end
    end
    it "rejects invalid keys" do
      world.enter do |db|
        result = world.room(test_data[:room]).not_nil!.key_valid? "bad-key", db
        result.should be_false
      end
    end
  end
end
