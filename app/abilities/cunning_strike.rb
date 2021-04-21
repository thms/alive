# TODO:
# Self: cleanse DoT
# Target lowest HP: remove critical increase, and attack increases.
# Reduce critical chance 100% and reduce Damage 50% for 2 attacks, 1 turn
# Attack 1x

class CunningStrike < Ability

  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:dot)
  end

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::Distract.new(distraction: 50, attacks: 2, turns: 1))
  end

end
