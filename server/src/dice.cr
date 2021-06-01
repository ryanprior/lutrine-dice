require "pegmatite"

record Dice, count : Int32, sides : Int32, constant : Int32 do
  def roll
    results = Array.new(count) { |_| Random.rand(1..sides) }
    Roll.new dice: self, results: results
  end
end

record Roll, dice : Dice, results : Array(Int32)

DiceGrammar = Pegmatite::DSL.define do
  whitespace = (char(' ') | char('\t')).repeat
  whitespace_pattern(whitespace)

  digit = range('0', '9')
  digits = digit.repeat
  number = (
    (char('-') >> digits) |
    (digits)
  ).named :number

  dice = (digits.named(:count) >> char('d') >> digits.named(:sides)).named :dice

  value = dice | number

  compound = (value ^ ((char('+') | char('-')).named(:sign) ^ value).repeat).named :compound

  compound.then_eof
end

module DiceReader
  def self.read(source : String)
    tokens = Pegmatite.tokenize(DiceGrammar, source)
    DiceReader.build(tokens, source)
  end

  def self.build(tokens : Array(Pegmatite::Token), source : String)
    iter = Pegmatite::TokenIterator.new(tokens)
    main = iter.next
    build_value(main, iter, source)
  end

  private def self.build_value(main, iter, source)
    kind, start, finish = main

    value = case kind
            when :number then source[start...finish].to_i32
            when :compound then build_compound(main, iter, source)
            else raise NotImplementedError.new(kind)
            end
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
