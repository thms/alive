# Base class for modifiers
# while they take the input and change it, they also need to keep track of turns and attacks.
# Phases of processing
#
class Modifiers::Modifier

  class_attribute :turns # number of turns this is active
  class_attribute :attacks # number of attacks this is active
  class_attribute :source # {:self, :opponent}
  class_attribute :probability # { in integer, 0..100}
  class_attribute :cleanse # [:all, :damage_over_time, :distraction]
  class_attribute :destroy # [:shields]
  class_attribute :tick_when_attacking # ticks down attacks when the dino is making an attack, e.g. using damage_increase
  class_attribute :tick_when_attacked # ticks down attacks when the dino is defending, e.g. using shields
  class_attribute :is_positive # if true, boosts the dinosaur, if negative hampers it

  # attributes to keep keep track for each instance of the ticking Clock
  attr_accessor :current_turns
  attr_accessor :current_attacks
  attr_accessor :value
  
  # set initial turns and attacks
  def initialize
    @current_attacks = self.attacks
    @current_turns = self.turns
  end

  # Clock advances after each round
  # returns true if the modifier should be deleted.
  def tick
    @current_turns -= 1
    if @current_turns <= 0
      # remove from the list of active modifiers of the current dinosaur
      return true
    else
      return false
    end
  end

  # Deplete after each attack this modifier is affecting
  # returns true if the modifier should be deleted.
  def tick_attacks
    return false if current_attacks.nil?
    @current_attacks -=1
    if @current_attacks <= 0
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
