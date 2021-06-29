class GroupAcceleration < Ability

  self.is_implemented = true
  self.cooldown = 1
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:decrease_speed)
    attacker.add_modifier(Modifiers::IncreaseSpeed.new(50, 3))
  end

end
