# TODO:
class GroupTauntingShields < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Taunt.new(1, nil))
    attacker.add_modifier(Modifiers::Shields.new(50, 2, 2))
  end
end
