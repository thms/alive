# TODO:
class DeceleratingRampage < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2.0
  self.bypass = []

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 2, nil))
  end


end
