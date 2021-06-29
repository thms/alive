class InstantInvincibilityTaunt < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(100, 0, 4))
    attacker.add_modifier(Modifiers::Taunt.new(1))
  end

end
