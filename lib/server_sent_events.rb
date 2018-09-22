# frozen_string_literal: true

require "uri"

require "server_sent_events/version"
require "server_sent_events/client"
require "server_sent_events/parser"

module ServerSentEvents
  # Convenience method go the up-and running fast.
  #
  # In order to start listening to server events, this is all the code that we
  # need:
  #
  #     ServerSentEvents.listen("http://example.com") do |event|
  #       puts event
  #     end
  def self.listen(address, headers = {}, &callback)
    Client.new(URI(address), Parser.new, headers).listen(&callback)
  end
end
