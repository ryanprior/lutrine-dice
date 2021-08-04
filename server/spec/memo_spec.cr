require "./spec_helper"

include Lutrine::Server

world = World.load

describe Memo, tags: "model" do
  describe Memo::Message do
    describe "#save" do
      it "creates new message records" do
        msg = Memo::Message.new id: nil,
                                room_id: TEST_DATA[:room],
                                from: "J. Random Hacker",
                                message: "Hello World"
        world.enter do |db|
          msg.save(db).should_not be_nil
        end
      end
      it "updates existing message records" do
        msg = Memo::Message.new id: 1,
                                room_id: TEST_DATA[:room],
                                from: "Hackerman",
                                message: "pwned"
        world.enter do |db|
          msg.save(db).should_not be_nil
        end
      end
    end
  end
  describe "#messages_for" do
    it "retrieves all messages for a given room" do
      world.enter do |db|
        messages = Memo.messages_for TEST_DATA[:room], db
        messages.size.should be > 0
      end
    end
  end
end
