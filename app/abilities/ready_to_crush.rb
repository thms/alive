class ReadyToCrush < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:distraction)
    attacker.cleanse(:critical)
    attacker.add_modifier(Modifiers::IncreaseCriticalChance.new(30, 4, 2))
    attacker.add_modifier(Modifiers::IncreaseDamage.new(50, 4, 2))
  end

end
