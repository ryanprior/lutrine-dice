module Base58
  ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".chars

  def self.random(n)
    String.build(n) do |result|
      n.times { result << ALPHABET.sample(Random::Secure) }
    end
  end
end
