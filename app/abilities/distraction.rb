# TODO:
class Distraction < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 1, 2))
  end

end
