class ResilientStrike < Ability

  self.is_implemented = true
  self.initial_cooldown = 0
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 1
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:distraction)
  end

  def update_defender(attacker, defender)
    defender.remove_dodge
    defender.remove_cloak
    defender.remove_speed_increase
    defender.add_modifier(Modifiers::DecreaseSpeed.new(50, 1))
  end

end
