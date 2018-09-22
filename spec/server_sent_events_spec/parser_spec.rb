# frozen_string_literal: true

require "server_sent_events/parser"

RSpec.describe ServerSentEvents::Parser do
  subject(:parser) { described_class.new }

  def assert_event(instance, id, event, data)
    expect(instance.id).to eq(id)
    expect(instance.event).to eq(event)
    expect(instance.data).to eq(data)
  end

  context "#push" do
    it "ignores lines starting with :" do
      expect(parser.push(": comment")).to eq([])
    end

    it "emits events on empty line" do
      events = parser.push("\n")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, nil, "")
    end

    it "parses single event data" do
      events = parser.push("id: 3\rdata: sample\n\r\n")
      expect(events.length).to eq(1)
      assert_event(events[0], "3", nil, "sample")
    end

    it "handles multiline data" do
      events = parser.push("data: line 1\ndata: line 2\r\r\n")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, nil, "line 1\nline 2")
    end

    it "emits multiple events" do
      events = parser.push("data: line 1\n\ndata: line 2\r\r")
      expect(events.length).to eq(2)
      assert_event(events[0], nil, nil, "line 1")
      assert_event(events[1], nil, nil, "line 2")
    end

    it "waits on partial data" do
      events = parser.push("data: line 1\r\n")
      expect(events.length).to eq(0)

      events = parser.push("data: line 2\n\n")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, nil, "line 1\nline 2")
    end

    it "emits all complete events" do
      events = parser.push("data: line 1\r\revent: custom")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, nil, "line 1")

      events = parser.push("\n")
      expect(events.length).to eq(0)

      events = parser.push("\n")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, "custom", "")
    end

    it "parser events with empty values" do
      events = parser.push("event\n\r")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, "", "")
    end

    it "parser events with intermixed fields" do
      events = parser.push("data: d1\nid: 5\ndata:d2\nevent\ndata: d3\n\n")
      expect(events.length).to eq(1)
      assert_event(events[0], "5", "", "d1\nd2\nd3")
    end

    it "strips leading space if present" do
      events = parser.push("data:d1\ndata: d2\ndata:  d3\n\n")
      expect(events.length).to eq(1)
      assert_event(events[0], nil, nil, "d1\nd2\n d3")
    end
  end
end
