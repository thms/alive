# TODO:
class GroupShield < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  # TODO: extend to group
  def update_attacker(attacker, defender)
    attacker.add_modifier(Modifiers::Shields.new(50, 2, 2))
  end
end
