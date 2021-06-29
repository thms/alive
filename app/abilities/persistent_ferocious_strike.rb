class PersistentFerociousStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::IncreaseDamage.new(50, 2, 2))
  end

end
