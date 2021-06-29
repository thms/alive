class TauntingBellow < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(50, 1, 4))
    attacker.add_modifier(Modifiers::Taunt.new(1))
  end

  def update_defender(attacker, defender)
    attacker.add_modifier(Modifiers::DecreaseSpeed.new(50, 2))
  end

end
