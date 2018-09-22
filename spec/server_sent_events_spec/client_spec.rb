# frozen_string_literal: true

require "net/http"

require "server_sent_events/client"
require "server_sent_events/event"
require "server_sent_events/parser"

RSpec.describe ServerSentEvents::Client do
  subject(:client) do
    described_class.new(URI("http://dummy.address"),
                        ServerSentEvents::Parser.new)
  end

  before do
    http = double
    response = double
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_yield(response)
    allow(response).to receive(:read_body)
      .and_yield("id: 1\r")
      .and_yield("data: line")
      .and_yield("\r\n")
      .and_yield(": comment")
      .and_yield("\nignore:me\n")
      .and_yield("\n")
  end

  context "#listen" do
    it "produces event from data" do
      event = ServerSentEvents::Event.new
      event.set("id", "1")
      event.set("data", "line")
      expect { |b| client.listen(&b) }.to yield_with_args(event)
    end
  end
end
