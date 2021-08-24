class DeliberateProwl < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    attacker.cleanse(:all)
    attacker.add_modifier(Modifiers::Dodge.new(75, 1, 2))
    attacker.add_modifier(Modifiers::IncreaseCriticalChance.new(50, 1, 2))
  end

end
