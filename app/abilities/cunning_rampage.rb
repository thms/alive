class CunningRampage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_defender(attacker, defender)
    defender.remove_critical_chance_increase
    defender.remove_attack_increase
    defender.add_modifier(Modifiers::ReduceCriticalChance.new(100, 1, 2))
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
  end

end
