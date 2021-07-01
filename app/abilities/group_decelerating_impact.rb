# TODO:
class GroupDeceleratingImpact < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1.5
  self.bypass = []

  def update_defender_after_damage(attacker, defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 2))
  end

end
