require "json"
require "../dice"

module Lutrine::Dice

  enum AdjustType
    Low
    High
  end

  record Adjust, sign : Int32, count : Int32, type : AdjustType do
    include JSON::Serializable
  end

  record Dice, count : Int32, sides : Int32, constant : Int32, adjust : Adjust? do
    include JSON::Serializable

    def roll
      return Roll.new dice: self, results: [0] * count if sides < 1
      return Roll.new dice: self, results: [count] if sides == 1
      Roll.new dice: self,
               results: Array.new(count) { |_| Random::Secure.rand(1..sides) }
    end
  end

  record Roll, dice : Dice, results : Array(Int32) do
    include JSON::Serializable
  end

  record Message, parts : Array(String | Array(Roll)) do
    include JSON::Serializable

    def self.from_string(message)
      msg = Lutrine::Dice::Reader.read message
      new(msg.map do |part|
            case part
            when Array(Dice)
              part.map(&.roll)
            else
              part
            end
          end)
    end
  end
end
