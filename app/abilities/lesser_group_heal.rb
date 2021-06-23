class LesserGroupHeal < Ability

  self.is_implemented = true
  self.initial_cooldown = 2
  self.initial_delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.current_health += [attacker.health - attacker.current_health, 1.0 * attacker.damage].min
    attacker.cleanse(:all)
  end

end
