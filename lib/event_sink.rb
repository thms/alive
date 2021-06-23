class EventSink

  @@events = []

  def self.events
    @@events
  end

  def self.reset
    @@events = []
  end

  def self.add(event)
    @@events.push event
  end
end
