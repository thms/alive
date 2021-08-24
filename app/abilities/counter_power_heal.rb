class CounterPowerHeal < Ability

  self.is_implemented = true
  self.cooldown = 0
  self.delay = 0
  self.is_priority = false
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker)
    attacker.heal(0.11 * attacker.health)
  end

end
