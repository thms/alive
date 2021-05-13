# Precise attack
class ShieldedDeceleratingStrike < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = [:dodge, :cloak]

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(50, 1, 4))
  end

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 2, nil))
  end
end
