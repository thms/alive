# TODO:
class ShieldedTauntingStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::Taunt.new(1, 8))
    attacker.add_modifier(Modifiers::Shields.new(50, 1, 4))
  end
end
