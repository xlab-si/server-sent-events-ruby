# frozen_string_literal: true

require "server_sent_events/event"

module ServerSentEvents
  # Instances of this class can be used to parse incoming data into {Event}s.
  # This class is most commonly used by the {Client} to convert data from the
  # server into series of events.
  #
  # This parser strictly follows the parsing and interpreting parts of the
  # [html spec][spec].
  #
  #  [spec]: https://html.spec.whatwg.org/multipage/server-sent-events.html
  #
  # To use the parser, simply create new instance and feed it data using
  # {#push} method:
  #
  #     parser = Parser.new
  #     loop do
  #       parser.push(get_data_from_somewhere).each do |event|
  #         do_something_with(event)
  #       end
  #     end
  class Parser
    LINE_DELIMITER = /\r\n|\r|\n/

    def initialize
      @buffer = ""
      @event = Event.new
    end

    # Add new data to parser.
    #
    # Newly pushed data is added to any remaining data from previous calls,
    # which is then checked for any complete events that are returned.
    #
    # Note that push can generate zero, one or more events, depending on data
    # from previous runs and currently passed-in data. After the call returns,
    # all complete events are returned (internal buffer contains only
    # incomplete event or is empty).
    #
    # @return [Array<Event>] complete events
    def push(data)
      @buffer += data
      process_buffer
    end

    private

    def process_buffer
      events = []
      start = 0
      while (index = @buffer.index(LINE_DELIMITER, start))
        event = process_buffer_line(@buffer[start...index])
        events << event if event
        start = index + (@buffer[index, 2] == "\r\n" ? 2 : 1)
      end
      @buffer = @buffer.slice(start..-1)
      events
    end

    def process_buffer_line(line)
      return emit_event if line.empty?
      return nil if line[0] == ":"

      key, value = line.split(":", 2)
      value = "" if value.nil?
      value = value.slice(1..-1) if value[0] == " "
      @event.set(key, value)
      nil
    end

    def emit_event
      e = @event
      @event = Event.new
      e
    end
  end
end
