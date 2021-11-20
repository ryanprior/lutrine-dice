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
    adjust_symbol = char('h') | char('l') | char('H') | char('L')
    sign = char('+') | char('-')
    drop = (
      char('-') ^ digits.named(:count).maybe >> adjust_symbol.named(:symbol)
    ).named :drop
    dice = (
      digits.maybe.named(:count) >> d >> digits.named(:sides) ^ drop.maybe.named(:drop)
    ).named :dice

    value = dice | number

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
        when :number then result << Dice.new source[start...finish].to_i32, 1, sign, nil
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
      drop = build_drop(iter.next_as_child_of(main), iter, source)

      case {count, sides}
      when {Int32, Int32} then Dice.new count, sides, sign, drop
      else raise NotImplementedError.new({count, sides})
      end
    end

    private def self.build_drop(main, iter, source)
      _, start, finish = main
      return nil if start == finish
      count = 1
      symbol = AdjustType::Low

      iter.while_next_is_child_of(main) do |child|
        kind, start, finish = child
        case kind
        when :count then count = source[start...finish].to_i32
        when :symbol then
          symbol = source[start...finish] =~ /[Hh]/ ? AdjustType::High : AdjustType::Low
        end
      end
      Adjust.new 1, count, symbol
    end
  end
end
