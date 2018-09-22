# frozen_string_literal: true

require "server_sent_events/event"

RSpec.describe ServerSentEvents do
  it "has a version number" do
    expect(ServerSentEvents::VERSION).not_to be nil
  end

  context ".listen" do
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

    it "produces event from data" do
      event = ServerSentEvents::Event.new
      event.set("id", "1")
      event.set("data", "line")
      expect { |b| described_class.listen("http://dummy.address", &b) }
        .to yield_with_args(event)
    end
  end
end
