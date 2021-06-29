class GreaterEmergencyHeal < Ability

  self.is_implemented = true
  self.cooldown = 2
  self.delay = 0
  self.is_priority = true
  self.damage_multiplier = 0
  self.bypass = []

  def update_attacker(attacker, defender)
    attacker.cleanse(:all)
    attacker.heal(2 * attacker.value)
  end

end
