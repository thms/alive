# TODO:
class LethalWound < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender(attacker, defender)
    defender.add_modifier(Modifiers::DamageOverTime.new(33.4, 3))
  end

end
