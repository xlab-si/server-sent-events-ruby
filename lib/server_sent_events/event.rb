# frozen_string_literal: true

module ServerSentEvents
  # Class that represents server event.
  #
  # This class can be used to construct new events on the server and then
  # serialize them for the transfer or is returned as a result of {Parser}
  # action on the client.
  class Event
    attr_reader :id, :event, :data

    def initialize
      @data = ""
    end

    # Set event key-value pair.
    #
    # Note that the only valid keys are `id`, `event` and `data`, last one
    # being a bit special. Calling `set("data", "some data")` will **apend**
    # this the string `some data` to existing data using newline as a
    # separator.
    #
    # @param key [String] key to use
    # @param value [String] data to set/append
    def set(key, value)
      case key
      when "id"    then @id = value
      when "event" then @event = value
      when "data"  then append_data(value)
      end
    end

    # Serialize event into form for transmission.
    #
    # Output of this method call can be written directly into the socket.
    def to_s
      repr = ""
      repr += "id: #{id}\n" if id
      repr += "event: #{event}\n" if event
      if data.empty?
        repr += "data: \n"
      else
        data.split("\n").each { |l| repr += "data: #{l}\n" }
      end
      repr += "\n"
    end

    def ==(other)
      other.id == id && other.event == event && other.data == data
    end

    private

    def append_data(chunk)
      @data = @data.empty? ? chunk : "#{@data}\n#{chunk}"
    end
  end
end
