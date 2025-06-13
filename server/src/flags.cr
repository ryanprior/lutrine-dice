module Lutrine::Flags

  private def self.env?(*allowed : String)
    allowed.includes? ENV.fetch("LUTRINE_ENV", "production")
  end

  def self.allow_cors?
    env? "testing", "local"
  end

  def self.public_dir
    ENV.fetch("LUTRINE_PUBLIC_DIR", "public")
  end

end
