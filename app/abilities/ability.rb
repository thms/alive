# Base class for an ability
# Phase 1: affect opponents shields, ciritcal chance, speed
# Phase 2: affect own distraction, DoT, speed, health
# Phase 3 deal damange to opponent
# Constructor: set attacker and defender

# Quick-Use Abilities
# Charged Abilities
# Counter-Attack Abilities
# Swap-In Abilities
# Swap-Out Abilities
# On-Escape Abilities
# Priority Abilities

class Ability

  # Store the original delay and cooldown as class_attributes, to be set in the derived class
  class_attribute :initial_delay
  class_attribute :initial_cooldown

  # is this a priority move?
  class_attribute :is_priority

  # Keep track of the current delay and cooldown
  attr_accessor :current_delay
  attr_accessor :current_cooldown

  def initialize
    @current_cooldown = 0 # cooldown only starts after an ability has been used, so initially there is none.
    @current_delay = self.initial_delay # delay is only until the first use of an ability afterwards it is don't care.
  end

  def tick
    if @current_delay > 0
      @current_delay -= 1
    elsif @current_cooldown > 0
      @current_cooldown -= 1
    end
  end

  def execute(attacker, defender)
    update_defender(attacker, defender)
    update_attacker(attacker, defender)
    damage_defender(attacker, defender)
    update_cooldown_attacker(attacker, defender)
  end

  # update defender's shields, etc.
  # need to push the modifyers onto the defender's list
  def update_defender(attacker, defender)
  end

  # update attacker's shields, etc.
  # need to push the modifyers onto the attacker's list
  def update_attacker(attacker, defender)
  end

  # update defender's current_health with the corresponding damage
  def damage_defender(attacker, defender)
  end

  # if there is a cooldown on the ability, update the attacker's ability stats, to start the cooldown
  # since this is executed before tick, cooldown needs to be +1
  def update_cooldown_attacker(attacker, defender)
    if self.initial_cooldown > 0
      # @attacker.ability_stats[self.class.name][:cooldown] = self.initial_cooldown + 1
      @current_cooldown = self.initial_cooldown + 1
    end
  end

end
