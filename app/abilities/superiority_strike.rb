class SuperiorityStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []
  self.bypass = [:dodge, :cloak]

  def update_defender_after_damage(defender)
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 1))
  end
end
