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
  class_attribute :delay
  class_attribute :cooldown

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

  # True if this is an "rampage and run" style ability leading to automatic swap out of the dino after the move
  class_attribute :is_swap_out
  self.is_swap_out = false

  # Keep track of the current delay and cooldown
  attr_accessor :current_delay
  attr_accessor :current_cooldown

  def name
    self.class.name
  end

  def initialize
    @current_cooldown = 0 # cooldown only starts after an ability has been used, so initially there is none.
    @current_delay = self.delay # delay is only until the first use of an ability afterwards it is don't care.
  end

  def is_available?
    current_delay <= 0 && current_cooldown <= 0
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
    # destroy shields, cloak dodge, before attacking
    update_defender(attacker, defender)
    # Tick down the attacker's shields at the top if his turn
    attacker.tick_shields
    # Tick down the attacker's shields at the top if his turn
    attacker.tick_dodge
    # increase damage
    update_attacker(attacker, defender)
    stats = damage_defender(attacker, defender)
    # add new modifiers for the defender, so they don't already get ticked down in damage _defender.
    update_defender_after_damage(attacker, defender)
    # execute counter attack, if defender survived and was attacked
    if defender && defender.has_counter? && !defender.is_stunned && defender.current_health > 0 && damage_multiplier > 0
      stats[:counter] = defender.abilities_counter.first.damage_defender(defender, attacker)
    end
    # start the cooldown period
    start_cooldown
    # trigger on escape ability of the attacker, if any
    on_escape(attacker, defender)
    stats
  end

  # update defender's shields, etc.
  # need to push the modifiers onto the defender's list
  def update_defender(attacker, defender)
  end

  # update attacker's shields, etc.
  # need to push the modifiers onto the attacker's list
  def update_attacker(attacker, defender)
  end

  # update defender's speed, distractions etc, after they have received a hit so they don't get ticked down during damage_defender already
  # need to push the modifiers onto the defender's list
  def update_defender_after_damage(attacker, defender)
  end

  # update defender's current_health with the corresponding damage
  def damage_defender(attacker, defender)
    # Don't deal damage if there is no defender (testing) or there is no damage to be done, e.g. when healing
    # don't tick down defender shields and others when healing, since there is no attack on them
    if damage_multiplier == 0 || defender.nil?
      retval = {is_critical_hit: false, did_dodge: false}
    else
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
      # Apply vulnerability
      damage = damage * (1.0 + 0.25 * (100.0 - defender.resistance(:vulnerable)) / 100.0) if defender.current_attributes[:vulnerable]
      # Apply distraction
      damage = (damage * (100.0 - attacker.current_attributes[:distraction] * (100.0 - attacker.resistance(:distraction)) / 100.0) / 100.0)
      # Attack increase
      damage = (damage * (100.0 + attacker.current_attributes[:damage]) / 100.0)
      # TODO: filter through defender's modifiers (dogde)
      did_dodge = (100 * rand < defender.current_attributes[:dodge]) && !bypass.include?(:dodge)
      damage = (damage * (100.0 - 66.7) / 100.0) if (did_dodge)
      # filter through defender's shields
      damage = (damage * (100 - defender.current_attributes[:shields]) / 100)
      # filter through defender's armor if any and the strike does not bypass armor
      damage = (damage * (100 - defender.armor) / 100) unless bypass.include?(:armor)
      # damage must no go below zero
      damage = [damage, 0].max
      # update defender's health and clamp all death to value 0
      defender.current_health = [(defender.current_health - damage).round, 0].max
      retval = {is_critical_hit: is_critical_hit, did_dodge: did_dodge}
      # count down defender's active modifiers and delete them if used up
      defender.tick_defense_count
    end
    # count down the attack ticks on the attacker's attack modifiers, after attacking and healing
    attacker.tick_attack_count
    # count down attacker's distraction (should also tick distraction when the attacker is stunned)
    attacker.tick_distraction
    retval
  end

  # if there is a cooldown on the ability, update the ability's stats, to start the cooldown
  # since this is executed before tick, cooldown needs to be +1
  def start_cooldown
    if self.cooldown > 0
      @current_cooldown = self.cooldown + 1
    end
  end

  # TODO: performs swapping out effects,
  def on_escape(attacker, defender)
  end

  def to_param
    self.class.name.parameterize
  end

end
