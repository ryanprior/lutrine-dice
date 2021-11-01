module Lutrine::Flags

  private def self.env?(*allowed : String)
    allowed.includes? ENV.fetch("LUTRINE_ENV", "production")
  end

  def self.allow_cors?
    env? "testing", "local"
  end

end
