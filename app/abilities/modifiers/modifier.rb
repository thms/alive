# Base class for modifiers
# while they take the input and change it, they also need to keep track of turns and attacks.
# Phases of processing
#
class Modifiers::Modifier

  class_attribute :turns # number of turns this is active
  class_attribute :attacks # number of attacks this is active
  class_attribute :source # {:self, :opponent}
  class_attribute :probability # { in flloat, 0..1.0}
  class_attribute :cleanse # [:all, :dot]

  # attributes to keep keep track for each instance of the ticking Clock
  attr_accessor :current_turns
  attr_accessor :current_attacks

  # set initial turns and attacks
  def initialize
    @current_attacks = self.attacks
    @current_turns = self.turns
  end

  # Clock advances after each round
  # returns true if it should be deleted.
  def tick
    @current_turns -=1
    if @current_turns < 0
      # remove from the list of active modifiers of the current dinosaur
      return true
    else
      return false
    end
  end


  def execute(attributes)
    attributes
  end

end
