# Base class for a move
# Phase 1: affect opponents shields, ciritcal chance, speed
# Phase 2: affect own distraction, DoT, speed, health
# Phase 3 deal damange to opponent
# Constructor: set attacker and defender
class Move

  def initialize(attacker, defender)
    @attacker = attacker
    @defender = defender
  end

  class_attribute :delay
  class_attribute :cooldown

  def execute
    update_defender
    update_attacker
    damage_defender
    update_cooldown_attacker
  end

  # update defender's shields, etc.
  # need to push the modifyers onto the defender's list
  def update_defender
  end

  # update attacker's shields, etc.
  # need to push the modifyers onto the attacker's list
  def update_attacker
  end

  # update defender's current_health with the corresponding damage
  def damage_defender
  end

  # if there is a cooldown on the move, update the attacker's move stats, to start the cooldown
  # since this is executed before tick, cooldown neds ot be +1
  def update_cooldown_attacker
    if self.cooldown > 0
      @attacker.move_stats[self.class.name][:cooldown] = self.cooldown + 1
    end
  end

  def to_s
    "#{@attacker.name} #{self.class.name} damage #{@attacker.damage} on health #{@defender.current_health}"
  end

end
