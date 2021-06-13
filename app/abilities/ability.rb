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

  # Helper to keep track of what has been completely implemented
  class_attribute :is_implemented
  self.is_implemented = false

  # Store the original delay and cooldown as class_attributes, to be set in the derived class
  class_attribute :initial_delay
  class_attribute :initial_cooldown

  # is this a priority move?
  class_attribute :is_priority

  # what does this bypass?
  class_attribute :bypass # [:armor, :dodge, :cloak]

  # damage multiplier for this move: attacker.damage * multiplier, will be applied.
  class_attribute :damage_multiplier

  # if true, this is a rending attack, doing damage based on the max health of the other critter
  class_attribute :is_rending_attack
  self.is_rending_attack = false

  # True if this is an automatic counter move
  class_attribute :is_counter

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

  # TODO: ability to force the random decisions (crit, dodge) one way or the other for the simulator
  def execute(attacker, defender)
    update_defender(attacker, defender)
    update_attacker(attacker, defender)
    stats = damage_defender(attacker, defender)
    # execute counter attack, if defender survived and attack is an attack
    if defender && defender.has_counter? && !defender.is_stunned && defender.current_health > 0 && damage_multiplier > 0
      stats[:counter] = defender.abilities_counter.first.damage_defender(defender, attacker)
    end
    update_cooldown_attacker(attacker, defender)
    stats
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
    return {is_critical_hit: false, did_dodge: false} if damage_multiplier == 0 || defender.nil?
    if is_rending_attack
      # in a rending attack the damage is based of the max health of the defender, apply resistence
      damage = defender.health * damage_multiplier * (100.0 - defender.resistance(:rend)) / 100.0
    else
      # attacker's original damage times the type of attack
      damage = attacker.damage * damage_multiplier
    end
    # Apply critical chance: with probility of dino.critical chance, increase the damage by 25%
    # note: modifiers may reduce critical chance to zero, in the current attributes
    is_critical_hit = (100 * rand < attacker.current_attributes[:critical_chance])
    damage = damage * 1.25 if is_critical_hit
    # TODO: filter through attacker's modifiers (distraction, increase attack)
    # Apply distraction
    damage = (damage * (100.0 - attacker.current_attributes[:distraction] * (100.0 - attacker.resistance(:distraction)) / 100.0) / 100.0)
    # Attack increase
    damage = (damage * (100.0 + attacker.current_attributes[:damage]) / 100.0)
    # TODO: filter through defender's modifiers (dogde)
    did_dodge = (100 * rand < defender.current_attributes[:dodge])
    damage = (damage * (100.0 - 66.7) / 100.0) if (did_dodge && !bypass.include?(:dodge))
    # filter through defender's shields
    damage = (damage * (100 - defender.current_attributes[:shields]) / 100)
    # filter through defender's armor if any and the strike does not bypass armor
    damage = (damage * (100 - defender.armor) / 100) unless bypass.include?(:armor)
    # damage must no go below zero
    damage = [damage, 0].max
    # update defender's health
    defender.current_health = (defender.current_health - damage).round
    # count down the attack ticks on the attacker and defenders active modifiers and delete them if used up
    attacker.tick_attack_count
    defender.tick_defense_count
    {is_critical_hit: is_critical_hit, did_dodge: did_dodge}
  end

  # if there is a cooldown on the ability, update the attacker's ability stats, to start the cooldown
  # since this is executed before tick, cooldown needs to be +1
  def update_cooldown_attacker(attacker, defender)
    if self.initial_cooldown > 0
      @current_cooldown = self.initial_cooldown + 1
    end
  end

end
