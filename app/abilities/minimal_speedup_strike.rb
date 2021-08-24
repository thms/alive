class MinimalSpeedupStrike < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker)
    attacker.add_modifier(Modifiers::IncreaseSpeed.new(10, 30))
  end

end
