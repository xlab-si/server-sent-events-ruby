# frozen_string_literal: true

require "uri"

require "server_sent_events/version"
require "server_sent_events/client"
require "server_sent_events/parser"

module ServerSentEvents
  # Convenience method to get up-and-running fast.
  #
  # In order to start listening to server events, this is all the code that we
  # need:
  #
  #     ServerSentEvents.listen("http://example.com") do |event|
  #       puts event
  #     end
  #
  # @param address [String, URI] SSE endpoint
  # @param headers [Hash] HTTP headers to use when connecting
  # @param callback code block that should be executed on event arrival
  def self.listen(address, headers = {}, &callback)
    Client.new(URI(address), Parser.new, headers).listen(&callback)
  end
end
