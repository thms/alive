# Base class for stragies to clean up code base.
class Strategy

  # Override in derived class
  # Takes attacker and defender and calculates the next move for the attacker
  def self.next_move(attacker, defender)
  end

  # Override in derived class, if the strategy can learn
  # Input: -1.0: loss, 0.0: draw, 1.0: win from the attacker's point of view
  def self.learn(outcome, attacker_value = nil)
  end

  # Override in derived class to save the state, e.g. Q table, or neural network, or cache
  # Convention: Save to tmp/#{class.name}.state
  def self.save
  end

  # Override in derived class to load the state, e.g. Q table, or neural network, or cache
  # Convention: Load from tmp/#{class.name}.state
  def self.load
  end

  def self.stats
    {}
  end

end
