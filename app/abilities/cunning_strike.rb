# Self: cleanse DoT
# Target lowest HP: remove critical increase, and attack increases.
# Reduce critical chance 100% and reduce Damage 50% for 2 attacks, 1 turn
# Attack 1x

class CunningStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:damage_over_time)
  end

  def update_defender(attacker, defender)
    defender.remove_critical_chance_increase
    defender.remove_attack_increase
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
    defender.add_modifier(Modifiers::ReduceCriticalChance.new(100, 1, 2))
  end

end
