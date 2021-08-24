class InstantDistraction < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::Distraction.new(100, 1, 2))
  end

end
