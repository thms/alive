# TODO:
class DistractingRampage < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 1
  self.is_priority = false
  self.damage_multiplier = 2
  self.bypass = []

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::Distraction.new(50, 2, 4))
  end

end
