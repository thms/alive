# TODO:
class TauntingShields < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Taunt.new(1, nil))
    attacker.add_modifier(Modifiers::Shields.new(40, 2, 4))
  end
end
