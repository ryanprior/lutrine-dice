require "pegmatite"
require "./models/dice"

module Lutrine::Dice

  Grammar = Pegmatite::DSL.define do
    whitespace = (char(' ') | char('\t')).repeat
    whitespace_pattern(whitespace)

    digit = range('0', '9')
    digits = digit.repeat(1)
    number = (
      (char('-') >> digits) \
      | digits
    ).named :number

    d = char('d') | char('D')
    dice = (digits.maybe.named(:count) >> d >> digits.named(:sides)).named :dice

    value = dice | number
    sign = char('+') | char('-')

    compound = ((value >> (whitespace.maybe >> sign.named(:sign) ^ value).repeat(1)) \
                | dice
               ).named :compound

    text = (~d >> ~digit >> any).repeat(1).named :text

    message = (
      text.maybe >> (
        compound | (d | digit).named(:text)).maybe
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
      _, start, finish = iter.next_as_child_of(main)
      count = source[start...finish].to_i32? || 1
      _, start, finish = iter.next_as_child_of(main)
      sides = source[start...finish].to_i32

      case {count, sides}
      when {Int32, Int32} then Dice.new count, sides, sign
      else raise NotImplementedError.new({count, sides})
      end
    end
  end
end
