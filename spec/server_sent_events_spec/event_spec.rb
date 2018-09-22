# frozen_string_literal: true

require "server_sent_events/event"

RSpec.describe ServerSentEvents::Event do
  subject(:event) { described_class.new }

  def assert_event(instance, id, event, data)
    expect(instance.id).to eq(id)
    expect(instance.event).to eq(event)
    expect(instance.data).to eq(data)
  end

  context "#set" do
    it "sets id field" do
      event.set("id", "5")
      assert_event(event, "5", nil, "")
    end

    it "sets event field" do
      event.set("event", "type")
      assert_event(event, nil, "type", "")
    end

    it "sets data field" do
      event.set("data", "line")
      assert_event(event, nil, nil, "line")
    end

    it "apends data to existing content" do
      event.set("data", "line 1")
      assert_event(event, nil, nil, "line 1")

      event.set("data", "line 2")
      assert_event(event, nil, nil, "line 1\nline 2")
    end

    %w[selection of bad keys here].each do |key|
      it "ignores unknown key '#{key}'" do
        event.set(key, "value")
        assert_event(event, nil, nil, "")
      end
    end
  end

  context "#to_s" do
    it "serializes event" do
      event.set("id", "3")
      event.set("event", "type")
      event.set("data", "line")
      expect(event.to_s).to eq("id: 3\nevent: type\ndata: line\n\n")
    end

    it "skips missing id" do
      event.set("event", "type")
      event.set("data", "line")
      expect(event.to_s).to eq("event: type\ndata: line\n\n")
    end

    it "skips missing event" do
      event.set("id", "3")
      event.set("data", "line")
      expect(event.to_s).to eq("id: 3\ndata: line\n\n")
    end

    it "serializes empty event" do
      expect(event.to_s).to eq("data: \n\n")
    end
  end
end
