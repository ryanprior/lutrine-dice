require "pegmatite"
require "json"

module Lutrine::Dice

  record Dice, count : Int32, sides : Int32, constant : Int32 do
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
      msg = Reader.read message
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

  Grammar = Pegmatite::DSL.define do
    whitespace = (char(' ') | char('\t')).repeat
    whitespace_pattern(whitespace)

    digit = range('0', '9')
    digits = digit.repeat(1)
    number = (
      (char('-') >> digits) |
      (digits)
    ).named :number

    dice = (digits.named(:count) >> char('d') >> digits.named(:sides)).named :dice

    value = dice | number

    compound = (value >> (whitespace.maybe >> (char('+') | char('-')).named(:sign) ^ value).repeat).named :compound

    text = (~char('d') >> ~range('0', '9') >> any).repeat(1).named :text

    message = (
      text.maybe >> (
        compound | (char('d') | range('0', '9')).named(:text)).maybe
    ).repeat.named :message

    message.then_eof
  end

  module Reader
    def self.read(source : String)
      tokens = Pegmatite.tokenize(Grammar, source)
      build(tokens, source)
    end

    def self.build(tokens : Array(Pegmatite::Token), source : String)
      iter = Pegmatite::TokenIterator.new(tokens)
      main = iter.next
      build_message(main, iter, source)
    end

    private def self.build_message(main, iter, source)
      result = Array(String | Array(Dice)).new

      iter.while_next_is_child_of(main) do |child|
        kind, start, finish = child
        case kind
        when :text then case !result.empty? && result.last
                        when String then result.push(result.pop.as(String) + source[start...finish])
                        else result << source[start...finish]
                        end
        when :compound then result << build_compound(child, iter, source)
        else raise NotImplementedError.new kind
        end
      end

      result
    end

    private def self.build_compound(main, iter, source)
      result = [] of Dice
      sign = 1

      iter.while_next_is_child_of(main) do |child|
        kind, start, finish = child
        case kind
        when :sign then sign = source[start...finish] === "+" ? 1 : -1
        when :dice then result << build_dice(child, iter, source, sign)
        when :number then result << Dice.new source[start...finish].to_i32, 1, sign
        else raise NotImplementedError.new kind
        end
      end

      result
    end

    private def self.build_dice(main, iter, source, sign)
      kind, start, finish = iter.next_as_child_of(main)
      count = source[start...finish].to_i32
      kind, start, finish = iter.next_as_child_of(main)
      sides = source[start...finish].to_i32

      case {count, sides}
      when {Int32, Int32} then Dice.new count, sides, sign
      else raise "Invalid Dice"
      end
    end
  end
end
