class DigInTaunt < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
    attacker.heal(attacker.damage)
    attacker.add_modifier(Modifiers::IncreaseSpeed.new(10, 2))
    attacker.add_modifier(Modifiers::Shields.new(50, 2, 0))
    attacker.add_modifier(Modifiers::Taunt.new(1))
  end

end
