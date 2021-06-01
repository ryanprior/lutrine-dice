# Lutrine Dice Server

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

You can compile & run this server two ways:

### Using Shards & Crystal

```sh-session
$ shards install
$ crystal run server/src/server.cr
```

### Using Docker Compose

```sh-session
$ docker-compose up server
```

## Data Structures

### Dice Vector

How do we represent a particular dice roll in memory?

#### Plain Vector

We could have an array of integers with each element representing the number of
dice of a particular size. For example:

```crystal
[1, 2]     # 1d4 + 2; equivalent to [0, 1, 2] and [0, 0, 0, 1, 2]
[2, 0, -1] # 2d6 (+ 0d4) - 1
# [d100, d20, d12, d10, d8, d6, d4, d1]
```

#### Weaknesses of plain vector approach:
In this system we can't represent unusual dice like 1d60, 1d5, 1d3. Do we care about this?

For one thing, it would be a regression from the behavior of DiceLog.

#### Record approach:

We could instead do:

```crystal
record Dice do
  count: Int32
  sides: Int32
end

# then we can represent an unusual dice roll like:
# 1d101 + 2d5 + 4d3
[Dice.new(count=1, sides=101), Dice.new(count=2, sides=5), Dice.new(count=4, sides=3)]
```

#### Weaknesses of record approach:

This is somewhat more verbose and requires that we serialize & deserialize these record types.


#### Additional commentary:

Should `2d4-1d4` yield a dice record representing 1d4, or two dice records
representing 2d4 - 1d4?

I suppose the least-surprising solution is to roll all the dice in the input and
add the results, rather than consolidating beforehand. Which would actually make
this a strength for the record approach, since the vector approach cannot
elegantly handle this behavior.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/server/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [your-name-here](https://github.com/your-github-user) - creator and maintainer
