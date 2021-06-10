class DeliberateProwl < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
    attacker.add_modifier(Modifiers::Dodge.new(75, 1, 2))
    attacker.add_modifier(Modifiers::IncreaseCriticalChance.new(50, 1, 2))
  end

end
