class FerociousImpact < Ability

  self.is_implemented = true
  self.cooldown = 3
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 2.25
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::IncreaseDamage.new(50, 3, 6))
  end

end
