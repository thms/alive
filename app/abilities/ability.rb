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

  # what does this bypass?
  class_attribute :bypass # [:armor, :dodge, :cloak]

  # damage multiplier for this move: attacker.damage * multiplier, will be applied.
  class_attribute :damage_multiplier

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
  # need to push the modifiers onto the attacker's list
  def update_attacker(attacker, defender)
  end

  # update defender's current_health with the corresponding damage
  def damage_defender(attacker, defender)
    # Bail out if there is no defender (testing) or there is no damage to be done, e.g. when healing
    return if damage_multiplier == 0 || defender.nil?
    # attacker's original damage
    damage = attacker.damage * damage_multiplier
    # filter through attacker's modifiers (distraction, increase)

    # apply critical chance
    # filter through defender's modifiers (dogde, cloak, etc.)
    # filter through defender's shields
    damage = (damage * (100 - defender.current_attributes[:shields]) / 100).to_i
    # filter through defender's armor if any and the strike does not bypass armor
    damage = (damage * (100 - defender.armor) / 100).to_i unless bypass.include?(:armor)
    # update defender's health
    defender.current_health -= damage
    # round it
    defender.current_health = defender.current_health.to_i
    # count down the attack ticks on the attacker and defenders active modifiers and delete them if used up
    attacker.tick_attack_count
    defender.tick_defense_count
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
