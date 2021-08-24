class CunningImpact < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

  def update_attacker(attacker)
    attacker.cleanse(:damage_over_time)
  end

  def update_defender(defender)
    defender.remove_critical_chance_increase
    defender.remove_attack_increase
  end

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::ReduceCriticalChance.new(100, 1, 2))
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
  end

end
