require "./dice"
require "json"

module Lutrine::Server
  record Actor, name : String do
    include JSON::Serializable
  end

  abstract class Action
    include JSON::Serializable
    property type : String
    use_json_discriminator "type", {message: MessageAction}
  end

  class MessageAction < Action
    property from : Actor
    property message : String | Array(String | Array(Lutrine::Dice::Roll))

    def roll
      msg = @message
      case msg
      when String
        @message = Lutrine::Dice::Message.from_string(msg).parts
        self
      else
        self
      end
    end
  end
end
